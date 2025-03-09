# Wally Toolchain Management Guide

This document provides instructions for building, packaging, and relocating the Wally toolchain for the CORE-V-WALLY RISC-V project.

## Prerequisites

- Linux environment with sufficient disk space (at least 20GB recommended)
- Administrative privileges (for installing system dependencies)
- Git and basic build tools installed
- Internet connection to download source packages

## Building the Toolchain

### Complete Toolchain (with Buildroot)

```bash
# 1. Set WALLY environment variable to the repository root
export WALLY=$(pwd)

# 2. Build the toolchain with date-stamped directory name
$WALLY/bin/wally-tool-chain-install.sh --clean $(pwd)/wally-toolchain-$(date +%Y%m%d)

# 3. Make the toolchain relocatable (important before packaging)
$WALLY/bin/wally-tool-chain-relocate.sh $(pwd)/wally-toolchain-$(date +%Y%m%d)

# 4. Package the toolchain as a tarball
tar -zcvf wally-toolchain-$(date +%Y%m%d).tar.gz wally-toolchain-$(date +%Y%m%d)

# 5. Move the tarball to a distribution location
mv wally-toolchain-$(date +%Y%m%d).tar.gz /path/to/suitable/location

# 6. Copy the site setup script to the toolchain
sudo cp $WALLY/bin/site-setup.sh /path/to/suitable/location/wally-toolchain-$(date +%Y%m%d)/site-setup.sh
```

### Minimal Toolchain (without Buildroot)

```bash
# 1. Set WALLY environment variable to the repository root
export WALLY=$(pwd)

# 2. Build the toolchain without buildroot
$WALLY/bin/wally-tool-chain-install.sh --clean --no-buildroot $(pwd)/wally-toolchain-nobr-$(date +%Y%m%d)

# 3. Make the toolchain relocatable (important before packaging)
$WALLY/bin/wally-tool-chain-relocate.sh $(pwd)/wally-toolchain-nobr-$(date +%Y%m%d)

# 4. Package the toolchain as a tarball
tar -zcvf wally-toolchain-nobr-$(date +%Y%m%d).tar.gz wally-toolchain-nobr-$(date +%Y%m%d)

# 5. Move the tarball to a distribution location
mv wally-toolchain-nobr-$(date +%Y%m%d).tar.gz /path/to/suitable/location

# 6. Copy the site setup script to the toolchain
sudo cp $WALLY/bin/site-setup.sh /path/to/suitable/location/wally-toolchain-nobr-$(date +%Y%m%d)/site-setup.sh
```

## Making the Toolchain Relocatable

After building the toolchain, you can make it relocatable (usable from any location) with the `wally-tool-chain-relocate.sh` script:

```bash
# Fix paths in the toolchain
$WALLY/bin/wally-tool-chain-relocate.sh /path/to/toolchain

# Fix paths in both the toolchain and another directory containing scripts
$WALLY/bin/wally-tool-chain-relocate.sh /path/to/toolchain /path/to/target/dir
```

This script:
- Fixes RPATH in ELF binaries
- Fixes shared library dependencies
- Updates hardcoded paths in scripts
- Corrects Python module imports and paths

## Installation and Usage

### Installing the Toolchain

1. Extract the tarball to the desired location:
   ```bash
   tar -xzf wally-toolchain-[date].tar.gz -C /opt/wally/
   ```

2. Update the `WALLY_RISCV` variable in `setup.sh` to point to the new toolchain:
   ```bash
   # In the Wally repository's setup.sh
   WALLY_RISCV=/opt/wally/wally-toolchain-[date]
   ```

### Using the Toolchain

Source the setup script to configure your environment:
```bash
source /path/to/cvw/setup.sh
```

This will set up all necessary environment variables and paths to use the toolchain.

## Troubleshooting

If you encounter issues with hardcoded paths after moving the toolchain, run the relocate script again:
```bash
$WALLY/bin/wally-tool-chain-relocate.sh /new/path/to/toolchain
```

---

**Note:** Always ensure your `setup.sh` references the correct toolchain directory after installation to a new location.
