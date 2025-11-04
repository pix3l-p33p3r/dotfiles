#!/usr/bin/env bash
# Hardware Acceleration Verification Script
# Quickly check if hardware acceleration is properly configured

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   Intel Hardware Acceleration Status${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}\n"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}⚠️  Do not run this script as root${NC}\n"
  exit 1
fi

# Function to check command exists
check_cmd() {
  if command -v "$1" &> /dev/null; then
    echo -e "${GREEN}✓${NC} $1 found"
    return 0
  else
    echo -e "${RED}✗${NC} $1 not found"
    return 1
  fi
}

# Function to run a check
run_check() {
  local title="$1"
  local cmd="$2"
  echo -e "\n${YELLOW}▶${NC} ${title}"
  echo "─────────────────────────────────────────────────────────"
  eval "$cmd"
}

# 1. Check required tools
echo -e "${YELLOW}Checking required tools...${NC}"
check_cmd "vainfo" || echo "  Install with: nix-shell -p libva-utils"
check_cmd "vdpauinfo" || echo "  Install with: nix-shell -p vdpauinfo"
check_cmd "vulkaninfo" || echo "  Install with: nix-shell -p vulkan-tools"
check_cmd "intel_gpu_top" || echo "  Install with: nix-shell -p intel-gpu-tools"

# 2. Environment Variables
run_check "Environment Variables" "echo 'LIBVA_DRIVER_NAME: $LIBVA_DRIVER_NAME'; echo 'VDPAU_DRIVER: $VDPAU_DRIVER'"

# 3. GPU Device
run_check "Intel GPU Device" "lspci | grep -i vga"

# 4. Kernel Module
run_check "i915 Kernel Module" "lsmod | grep i915 | head -n 1"

# 5. GuC/HuC Firmware
run_check "GuC/HuC Firmware Status" "sudo dmesg | grep -i 'guc\|huc' | tail -n 5"

# 6. Device Permissions
run_check "DRI Device Permissions" "ls -la /dev/dri/"

# 7. User Groups
run_check "User Groups" "groups | grep -E 'video|render'"

# 8. VA-API Check
if command -v vainfo &> /dev/null; then
  run_check "VA-API Status" "vainfo 2>&1 | head -n 20"
fi

# 9. VDPAU Check
if command -v vdpauinfo &> /dev/null; then
  run_check "VDPAU Status" "vdpauinfo 2>&1 | head -n 15"
fi

# 10. Vulkan Check
if command -v vulkaninfo &> /dev/null; then
  run_check "Vulkan Status" "vulkaninfo --summary 2>&1 | head -n 20"
fi

# 11. OpenCL Check
if command -v clinfo &> /dev/null; then
  run_check "OpenCL Status" "clinfo | grep -A 5 'Platform Name'"
fi

# Summary
echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Summary:${NC}"

# Check if VA-API is working
if vainfo 2>&1 | grep -q "iHD"; then
  echo -e "${GREEN}✓${NC} VA-API: Working (iHD driver)"
elif vainfo 2>&1 | grep -q "i965"; then
  echo -e "${YELLOW}⚠${NC} VA-API: Working (legacy i965 driver)"
else
  echo -e "${RED}✗${NC} VA-API: Not working"
fi

# Check if Vulkan is working
if vulkaninfo --summary 2>&1 | grep -q "Intel"; then
  echo -e "${GREEN}✓${NC} Vulkan: Working"
else
  echo -e "${RED}✗${NC} Vulkan: Not working"
fi

# Check if OpenCL is working
if command -v clinfo &> /dev/null && clinfo 2>&1 | grep -q "Intel"; then
  echo -e "${GREEN}✓${NC} OpenCL: Working"
else
  echo -e "${YELLOW}⚠${NC} OpenCL: Not tested (clinfo not installed)"
fi

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}\n"

echo -e "For detailed documentation, see:"
echo -e "  ${BLUE}machines/alucard/HARDWARE-ACCELERATION.md${NC}\n"

echo -e "To monitor GPU in real-time:"
echo -e "  ${GREEN}intel_gpu_top${NC}\n"

