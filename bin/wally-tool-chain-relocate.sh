#!/bin/bash

# Default toolchain directory
TOOLCHAIN_DIR=${2:-$(pwd)/wally-toolchain}

# Generate a timestamp for versioning (YYYYMMDD)
TIMESTAMP=$(date +"%Y%m%d")

# Define tarball name with date
TARBALL_NAME="wally-toolchain-portable-${TIMESTAMP}.tar.gz"

# Check if mode argument is provided
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 --check|--fix|--package [toolchain_directory]"
    exit 1
fi

MODE=$1

# Ensure patchelf is installed if fixing or packaging
if [[ "$MODE" == "--fix" || "$MODE" == "--package" ]] && ! command -v patchelf &>/dev/null; then
    echo "❌ Error: patchelf is not installed. Install it first (e.g., apt install patchelf or pacman -S patchelf)."
    exit 1
fi

# Arrays to store issues found
FOUND_ISSUES=()
FIXABLE_ISSUES=()
NON_FIXABLE_ISSUES=()

# Function to check ELF binaries for hardcoded paths
check_binaries() {
    echo "📂 Scanning ELF binaries for hardcoded paths..."
    find "$TOOLCHAIN_DIR" -type f -exec file {} + | grep 'ELF' | cut -d: -f1 | while read -r bin; do
        if readelf -d "$bin" | grep -q 'RPATH\|RUNPATH'; then
            issue="❌ Hardcoded RPATH/RUNPATH in: $bin [FIXABLE]"
            FOUND_ISSUES+=("$issue")
            FIXABLE_ISSUES+=("$issue")
        fi
        if ldd "$bin" 2>/dev/null | grep -E '=> /' | grep -q "$TOOLCHAIN_DIR"; then
            issue="❌ Shared library dependency issue in: $bin [FIXABLE]"
            FOUND_ISSUES+=("$issue")
            FIXABLE_ISSUES+=("$issue")
        fi
    done
}

# Function to check scripts and config files for hardcoded paths
check_scripts() {
    echo "📜 Scanning scripts and config files for hardcoded paths..."
    while IFS= read -r line; do
        file_path=$(echo "$line" | cut -d: -f1)
        path_match=$(echo "$line" | cut -d: -f2-)
        if [[ "$file_path" == *".sh" || "$file_path" == *".py" || "$file_path" == *".pl" || "$file_path" == *"Makefile"* ]]; then
            issue="❌ Hardcoded path in script: $file_path (Reference: $path_match) [FIXABLE]"
            FIXABLE_ISSUES+=("$issue")
        else
            issue="❌ Hardcoded path in config: $file_path (Reference: $path_match) [NON-FIXABLE]"
            NON_FIXABLE_ISSUES+=("$issue")
        fi
        FOUND_ISSUES+=("$issue")
    done < <(grep -rE '/(usr|opt|home|root|build|wally-toolchain)' "$TOOLCHAIN_DIR" --include="*.sh" --include="*.py" --include="*.pl" --include="*.la" --include="*.pc" --include="*.cfg" --include="*.conf" --include="*.json" --include="Makefile*" || true)
}

# Function to display a summary of issues found
print_summary() {
    echo -e "\n🔎 Summary of Issues Found:"
    for issue in "${FOUND_ISSUES[@]}"; do
        echo "$issue"
    done
    
    echo -e "\n📊 Summary Report:"
    echo "- Total Issues Found: ${#FOUND_ISSUES[@]}"
    echo "- Fixable Issues: ${#FIXABLE_ISSUES[@]}"
    echo "- Non-Fixable Issues: ${#NON_FIXABLE_ISSUES[@]}"
}

# Run in check mode
if [[ "$MODE" == "--check" ]]; then
    check_binaries
    check_scripts
    print_summary
    echo "✅ Relocatability check complete!"
    exit 0
fi

# Function to fix RPATH in ELF binaries
fix_rpath() {
    echo "🔄 Fixing RPATH in ELF binaries..."
    find "$TOOLCHAIN_DIR" -type f -exec file {} + | grep 'ELF' | cut -d: -f1 | while read -r bin; do
        if readelf -d "$bin" | grep -q 'RPATH\|RUNPATH'; then
            patchelf --set-rpath '$ORIGIN/../lib:$ORIGIN/../lib64' "$bin"
        fi
    done
}

# Function to fix shared library dependencies
fix_sysroot() {
    echo "🔄 Fixing shared library dependencies..."
    find "$TOOLCHAIN_DIR" -type f -exec file {} + | grep 'ELF' | cut -d: -f1 | while read -r bin; do
        if ldd "$bin" 2>/dev/null | grep -E '=> /' | grep -q "$TOOLCHAIN_DIR"; then
            patchelf --set-interpreter "\$ORIGIN/../lib/ld.so" "$bin"
        fi
    done
}

# Function to package the toolchain into a relocatable tarball
package_toolchain() {
    echo "📦 Creating relocatable tarball: $TARBALL_NAME"
    fix_rpath
    fix_sysroot
    tar -czvf "$TARBALL_NAME" -C "$(dirname "$TOOLCHAIN_DIR")" "$(basename "$TOOLCHAIN_DIR")"
    echo "✅ Packaging complete: $TARBALL_NAME"
}

# Run in the specified mode
if [[ "$MODE" == "--fix" ]]; then
    fix_rpath
    fix_sysroot
    echo "✅ Relocatability fixes applied!"
elif [[ "$MODE" == "--package" ]]; then
    package_toolchain
else
    echo "❌ Invalid option: Use --check, --fix, or --package"
    exit 1
fi