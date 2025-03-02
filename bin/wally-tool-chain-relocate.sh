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

fix_scripts() {
    echo "🔄 Fixing hardcoded paths in scripts..."
    find "$TARGET_DIR" -type f -print0 |
    while IFS= read -r -d $'\0' script; do
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

# Run the fixes
fix_rpath
fix_sysroot
fix_scripts
echo "✅ Relocatability fixes applied!"
