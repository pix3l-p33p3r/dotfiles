#!/usr/bin/env bash
set -euo pipefail

# This script removes legacy boot entries from the /boot/EFI/nixos/ directory
# that are no longer needed when using Lanzaboote with UKIs.

echo "Checking for legacy boot entries in /boot/EFI/nixos/..."

# Check if the directory exists
if [ ! -d "/boot/EFI/nixos" ]; then
  echo "✓ No legacy boot directory found. Nothing to clean up."
  exit 0
fi

# List what's in the legacy directory
echo ""
echo "Legacy boot entries found:"
sudo ls -lh /boot/EFI/nixos/ | grep -E '\.efi$' || echo "  (none)"

# Warn user
echo ""
echo "⚠️  WARNING: This will remove legacy boot entries."
echo "Current boot method: $(sudo bootctl status | grep 'Current Entry' || echo 'Unknown')"
echo ""
echo "Are you sure you want to remove /boot/EFI/nixos/? [y/N]"
read -r response

if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

# Backup first
BACKUP_DIR="/boot/EFI/backup-$(date +%Y%m%d-%H%M%S)"
echo ""
echo "Creating backup at: $BACKUP_DIR"
sudo mkdir -p "$BACKUP_DIR"
sudo cp -r /boot/EFI/nixos "$BACKUP_DIR/" || true

# Remove legacy entries
echo ""
echo "Removing legacy boot entries..."
sudo rm -rf /boot/EFI/nixos

echo ""
echo "✓ Cleanup complete!"

# Note: sbctl verify checks all EFI files, including backups
echo ""
echo "Verifying signed boot entries (backup files may show as unsigned)..."
sudo sbctl verify 2>&1 | grep -v "backup-" || true

echo ""
echo "To restore from backup if needed:"
echo "  sudo mv $BACKUP_DIR/nixos /boot/EFI/nixos"

