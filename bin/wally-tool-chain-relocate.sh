#!/bin/bash

# Default toolchain directory and target directory
TOOLCHAIN_DIR=${1:-$(pwd)/wally-toolchain}
TARGET_DIR=${2:-$TOOLCHAIN_DIR}  # By default, look in the toolchain dir

# Ensure patchelf is installed
if ! command -v patchelf &>/dev/null; then
    echo "❌ Error: patchelf is not installed. Install it first (e.g., apt install patchelf or pacman -S patchelf)."
    exit 1
fi

# Function to fix RPATH in ELF binaries
fix_rpath() {
    echo "🔄 Fixing RPATH in ELF binaries..."
    # First fix toolchain binaries
    find "$TOOLCHAIN_DIR" -type f -exec file {} + | grep 'ELF' | cut -d: -f1 | while read -r bin; do
        if readelf -d "$bin" | grep -q 'RPATH\|RUNPATH'; then
            patchelf --set-rpath '$ORIGIN/../lib:$ORIGIN/../lib64' "$bin"
        fi
    done
    
    # If target dir is different, also fix binaries there
    if [ "$TARGET_DIR" != "$TOOLCHAIN_DIR" ]; then
        find "$TARGET_DIR" -type f -exec file {} + | grep 'ELF' | cut -d: -f1 | while read -r bin; do
            if readelf -d "$bin" | grep -q 'RPATH\|RUNPATH'; then
                echo "  Fixing RPATH in external binary: $bin"
                patchelf --set-rpath '$ORIGIN/../lib:$ORIGIN/../lib64' "$bin"
            fi
        done
    fi
}

# Function to fix shared library dependencies
fix_sysroot() {
    echo "🔄 Fixing shared library dependencies..."
    # First fix toolchain binaries
    find "$TOOLCHAIN_DIR" -type f -exec file {} + | grep 'ELF' | cut -d: -f1 | while read -r bin; do
        if ldd "$bin" 2>/dev/null | grep -E '=> /' | grep -q "$TOOLCHAIN_DIR"; then
            patchelf --set-interpreter "\$ORIGIN/../lib/ld.so" "$bin"
        fi
    done
    
    # If target dir is different, also fix binaries there
    if [ "$TARGET_DIR" != "$TOOLCHAIN_DIR" ]; then
        find "$TARGET_DIR" -type f -exec file {} + | grep 'ELF' | cut -d: -f1 | while read -r bin; do
            if ldd "$bin" 2>/dev/null | grep -E '=> /' | grep -q "$TOOLCHAIN_DIR"; then
                echo "  Fixing interpreter in external binary: $bin"
                patchelf --set-interpreter "\$ORIGIN/../lib/ld.so" "$bin"
            fi
        done
    fi
}

# Function to fix hardcoded paths in scripts
fix_scripts() {
    echo "🔄 Fixing hardcoded paths in scripts..."
    find "$TARGET_DIR" -type f -print0 |
    while IFS= read -r -d $'\0' script; do
        # Skip Python scripts - they'll be handled by fix_python_imports
        if [[ "$script" == *.py ]]; then
            continue
        fi
        
        # Skip scripts that call python directly
        if head -n 1 "$script" | grep -q '^#!.*python'; then
            continue
        fi
        
        if head -n 1 "$script" | grep -q '^#!\s*/'; then
            echo "  Processing script: $script"

            # 1. Fix the shebang line (if necessary)
            interpreter=$(head -n 1 "$script" | sed 's/^#!\s*//')
            if [[ "$interpreter" == *"$TOOLCHAIN_DIR"* ]]; then
                relative_interpreter=$(echo "$interpreter" | sed "s|$TOOLCHAIN_DIR|.\/\$(dirname \$(dirname \"\$0\"))|")
                echo "  Replacing shebang with: #!$relative_interpreter"
                sed -i "1s|^#!\s*.*|#\!$relative_interpreter|" "$script"
            fi

            # 2. Replace hardcoded paths in the entire script
            if grep -q "$TOOLCHAIN_DIR" "$script"; then
                echo "  Replacing hardcoded paths in script body"
                sed -i "s|$TOOLCHAIN_DIR|\$(dirname \$(dirname \"\$0\"))|g" "$script"
            fi
        fi
    done
}

# Function to fix Python imports and paths
fix_python_imports() {
    echo "🔄 Fixing Python module imports..."
    
    # Detect Python version in the virtual environment
    PYTHON_LIB_DIR=$(find "$TOOLCHAIN_DIR/riscv-python/lib" -maxdepth 1 -type d -name "python*" | head -1)
    if [ -z "$PYTHON_LIB_DIR" ]; then
        echo "⚠️ Could not detect Python library directory, skipping Python fixes"
        return
    fi
    
    PYTHON_VERSION=$(basename "$PYTHON_LIB_DIR")
    echo "  Detected Python version: $PYTHON_VERSION"
    
    # Create a Python wrapper script that adjusts sys.path at runtime
    python_wrapper="$TOOLCHAIN_DIR/bin/python-wrapper.sh"
    cat > "$python_wrapper" << 'EOF'
#!/bin/bash
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
TOOLCHAIN_ROOT=$(dirname "$SCRIPT_DIR")
ORIG_PYTHON="$TOOLCHAIN_ROOT/riscv-python/bin/python"
VENV_ACTIVATE="$TOOLCHAIN_ROOT/riscv-python/bin/activate"

# Source the virtual environment
if [ -f "$VENV_ACTIVATE" ]; then
    source "$VENV_ACTIVATE"
fi

# Adjust Python path to find modules relative to toolchain root
export PYTHONPATH="$TOOLCHAIN_ROOT:$TOOLCHAIN_ROOT/sim/verilator:$PYTHONPATH"

# Execute Python with proper path
exec "$ORIG_PYTHON" "$@"
EOF
    chmod +x "$python_wrapper"
    
    # For each Python script that might reference the toolchain
    find "$TARGET_DIR" -type f -name "*.py" -o -name "*.sh" -o -name "*.bash" | xargs grep -l "$TOOLCHAIN_DIR" 2>/dev/null | while read -r script; do
        echo "  Fixing Python references in: $script"
        
        # If it's a Python script
        if [[ "$script" == *.py ]]; then
            # Fix direct path references in Python
            sed -i "s|$TOOLCHAIN_DIR|os.path.dirname(os.path.dirname(os.path.dirname(__file__)))|g" "$script"
        else
            # Replace direct Python calls with the wrapper in shell scripts
            sed -i "s|$TOOLCHAIN_DIR/riscv-python/bin/python|$(dirname \$(dirname \"\$0\"))/bin/python-wrapper.sh|g" "$script"
            # Fix other common virtual environment references
            sed -i "s|source $TOOLCHAIN_DIR/riscv-python/bin/activate|source \$(dirname \$(dirname \"\$0\"))/riscv-python/bin/activate|g" "$script"
            # Fix any other toolchain references
            sed -i "s|$TOOLCHAIN_DIR|\$(dirname \$(dirname \"\$0\"))|g" "$script"
        fi
    done
    
    # Create a .pth file to add our custom paths
    if [ -d "$TOOLCHAIN_DIR/riscv-python/lib/$PYTHON_VERSION/site-packages" ]; then
        echo "  Creating custom .pth file for Python path management"
        cat > "$TOOLCHAIN_DIR/riscv-python/lib/$PYTHON_VERSION/site-packages/toolchain_paths.pth" << 'EOF'
import os, sys
toolchain_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
sim_dir = os.path.join(toolchain_root, 'sim', 'verilator')
if os.path.exists(sim_dir):
    sys.path.insert(0, sim_dir)
EOF
    fi
}

# Function to fix the bin2hex script that calls freedom-bin2hex.py
fix_bin2hex_script() {
    echo "🔄 Fixing bin2hex script..."
    
    # Find the bin2hex script
    BIN2HEX_SCRIPT=$(find "$TOOLCHAIN_DIR/bin" -name "riscv64-unknown-elf-bin2hex" | head -1)
    if [ -n "$BIN2HEX_SCRIPT" ]; then
        echo "  Found bin2hex script: $BIN2HEX_SCRIPT"
        
        # Update the script to remove the problematic single quotes
        cat > "$BIN2HEX_SCRIPT" << 'EOF'
#!/bin/sh
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
TOOLCHAIN_ROOT=$(dirname "$SCRIPT_DIR")
exec "$TOOLCHAIN_ROOT/riscv-python/bin/python" -u "$TOOLCHAIN_ROOT/lib/python3.12/site-packages/freedom-bin2hex.py" ${1+"$@"}
EOF
        chmod +x "$BIN2HEX_SCRIPT"
        echo "  Fixed bin2hex script"
    else
        echo "  Could not find bin2hex script, skipping fix"
    fi
}

# Run the fixes
fix_rpath
fix_sysroot
fix_scripts
fix_python_imports
fix_bin2hex_script
echo "✅ Relocatability fixes applied!"
