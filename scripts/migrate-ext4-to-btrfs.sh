#!/usr/bin/env bash
# Migrate ext4 to Btrfs (in-place, non-destructive)
# Based on MIGRATE-EXT4-TO-BTRFS.md
# 
# IMPORTANT: Run this from a NixOS live ISO
# Requires: LUKS unlock, root partition identification

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration (adjust if needed)
ROOT_PARTITION="${ROOT_PARTITION:-/dev/nvme0n1p3}"
LUKS_UUID="${LUKS_UUID:-77036ffc-3333-4526-bbe8-c0a6ca58e92e}"
LUKS_MAPPER="${LUKS_MAPPER:-cryptroot}"
DOTFILES_PATH="${DOTFILES_PATH:-/home/pixel-peeper/dotfiles}"
FLAKE_CONFIG="${FLAKE_CONFIG:-alucard}"

# Mount points
MOUNT_ROOT="/mnt"
MOUNT_NEWROOT="/mnt/newroot"

# Subvolumes to create (excluding @ which is created separately)
SUBVOLUMES=("@home" "@nix" "@var_log" "@snapshots")

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

confirm() {
    local prompt="$1"
    local response
    read -p "$(echo -e ${YELLOW}${prompt}${NC} [y/N]: )" response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_live_iso() {
    # Check if we're likely on a live ISO (not mounted root filesystem)
    if mountpoint -q /mnt && [[ -d /mnt/etc/nixos ]]; then
        log_warning "It looks like you might already have a system mounted at /mnt"
        if ! confirm "Continue anyway"; then
            exit 1
        fi
    fi
}

identify_partitions() {
    log_info "Identifying partitions..."
    echo
    lsblk -f
    echo
    log_info "Detected root partition: ${ROOT_PARTITION}"
    log_info "LUKS UUID: ${LUKS_UUID}"
    
    if ! confirm "Is this correct? You can set ROOT_PARTITION and LUKS_UUID environment variables if different"; then
        log_error "Please set ROOT_PARTITION and LUKS_UUID environment variables and rerun"
        exit 1
    fi
}

unlock_luks() {
    log_info "Unlocking LUKS encrypted device..."
    local luks_device="/dev/disk/by-uuid/${LUKS_UUID}"
    
    if [[ ! -e "$luks_device" ]]; then
        log_error "LUKS device not found: $luks_device"
        exit 1
    fi
    
    # Check if already unlocked
    if [[ -e "/dev/mapper/${LUKS_MAPPER}" ]]; then
        log_warning "LUKS device already unlocked at /dev/mapper/${LUKS_MAPPER}"
        if confirm "Continue with existing unlock"; then
            return 0
        fi
    fi
    
    cryptsetup luksOpen "$luks_device" "$LUKS_MAPPER"
    log_success "LUKS device unlocked"
}

convert_to_btrfs() {
    local device="/dev/mapper/${LUKS_MAPPER}"
    
    log_info "Converting ext4 to Btrfs (this may take a while)..."
    log_warning "This is non-destructive - your ext4 will be preserved as ext2_saved"
    
    if ! confirm "Proceed with btrfs-convert"; then
        exit 1
    fi
    
    log_info "Running e2fsck..."
    e2fsck -f "$device" || {
        log_error "e2fsck failed. Fix filesystem errors first."
        exit 1
    }
    
    log_info "Converting to Btrfs..."
    btrfs-convert "$device" || {
        log_error "btrfs-convert failed"
        exit 1
    }
    
    log_success "Converted to Btrfs successfully"
}

create_subvolumes() {
    log_info "Creating Btrfs subvolumes..."
    
    local device="/dev/mapper/${LUKS_MAPPER}"
    
    # Mount top-level subvolume
    mount -o subvolid=5 "$device" "$MOUNT_ROOT" || {
        log_error "Failed to mount top-level Btrfs"
        exit 1
    }
    
    # Create @ subvolume first (root)
    log_info "Creating subvolume: @"
    btrfs subvolume create "${MOUNT_ROOT}/@" || {
        log_error "Failed to create subvolume: @"
        exit 1
    }
    
    # Create other subvolumes
    for subvol in "${SUBVOLUMES[@]}"; do
        log_info "Creating subvolume: $subvol"
        btrfs subvolume create "${MOUNT_ROOT}/${subvol}" || {
            log_error "Failed to create subvolume: $subvol"
            exit 1
        }
    done
    
    log_success "All subvolumes created"
}

move_data_to_subvolumes() {
    log_info "Moving data into subvolumes..."
    
    local device="/dev/mapper/${LUKS_MAPPER}"
    
    # Mount @ as new root
    mount -o subvol=@ "$device" "$MOUNT_NEWROOT" || {
        log_error "Failed to mount @ subvolume"
        exit 1
    }
    
    log_info "Copying data (this may take a while)..."
    rsync -aHAX --info=progress2 "$MOUNT_ROOT/" "$MOUNT_NEWROOT/" \
        --exclude=@ \
        --exclude=@home \
        --exclude=@nix \
        --exclude=@var_log \
        --exclude=@snapshots || {
        log_error "rsync failed"
        exit 1
    }
    
    # Create mount points and mount subvolumes
    mkdir -p "$MOUNT_NEWROOT"/{home,nix,var/log,.snapshots}
    
    mount -o subvol=@home "$device" "$MOUNT_NEWROOT/home" || {
        log_error "Failed to mount @home"
        exit 1
    }
    
    mount -o subvol=@nix "$device" "$MOUNT_NEWROOT/nix" || {
        log_error "Failed to mount @nix"
        exit 1
    }
    
    mount -o subvol=@var_log "$device" "$MOUNT_NEWROOT/var/log" || {
        log_error "Failed to mount @var_log"
        exit 1
    }
    
    mount -o subvol=@snapshots "$device" "$MOUNT_NEWROOT/.snapshots" || {
        log_error "Failed to mount @snapshots"
        exit 1
    }
    
    log_success "Data moved to subvolumes"
}

verify_migration() {
    log_info "Verifying migration..."
    
    if [[ ! -d "$MOUNT_NEWROOT/home/pixel-peeper" ]]; then
        log_warning "/home/pixel-peeper not found - this might be expected"
    fi
    
    if [[ ! -d "$MOUNT_NEWROOT/nix" ]]; then
        log_error "/nix directory not found"
        exit 1
    fi
    
    log_info "Listing subvolumes:"
    btrfs subvolume list "$MOUNT_NEWROOT"
    
    log_success "Verification complete"
}

rebuild_nixos() {
    log_info "Preparing to rebuild NixOS..."
    
    if [[ ! -d "$MOUNT_NEWROOT$DOTFILES_PATH" ]]; then
        log_warning "Dotfiles not found at $MOUNT_NEWROOT$DOTFILES_PATH"
        if ! confirm "Continue with rebuild anyway (you may need to clone dotfiles first)"; then
            log_info "Skipping rebuild. You can rebuild manually later:"
            log_info "  sudo nixos-enter --root $MOUNT_NEWROOT -- nixos-rebuild switch --flake $DOTFILES_PATH#$FLAKE_CONFIG"
            return 0
        fi
    fi
    
    # Bind mount system directories
    log_info "Bind mounting system directories..."
    mount --rbind /dev  "$MOUNT_NEWROOT/dev"
    mount --rbind /proc "$MOUNT_NEWROOT/proc"
    mount --rbind /sys  "$MOUNT_NEWROOT/sys"
    
    log_info "Rebuilding NixOS (this may take a while)..."
    chroot "$MOUNT_NEWROOT" /bin/sh -c \
        "nixos-rebuild switch --flake $DOTFILES_PATH#$FLAKE_CONFIG" || {
        log_error "NixOS rebuild failed"
        log_warning "You can try rebuilding manually:"
        log_warning "  sudo nixos-enter --root $MOUNT_NEWROOT -- nixos-rebuild switch --flake $DOTFILES_PATH#$FLAKE_CONFIG"
        return 1
    }
    
    log_success "NixOS rebuild complete"
}

cleanup_ext4_image() {
    local device="/dev/mapper/${LUKS_MAPPER}"
    
    log_warning "The ext4 image (ext2_saved) is still preserved for rollback"
    log_info "This takes up space. You can remove it later when you're confident the migration worked:"
    log_info "  sudo btrfs-convert -i $device"
    
    if confirm "Remove ext4 image now (NOT RECOMMENDED - wait a few days first)"; then
        btrfs-convert -i "$device" || {
            log_error "Failed to remove ext4 image"
            return 1
        }
        log_success "Ext4 image removed"
    fi
}

main() {
    cat << EOF
${BLUE}
╔══════════════════════════════════════════════════════════════╗
║         ext4 → Btrfs Migration Script                        ║
╚══════════════════════════════════════════════════════════════╝
${NC}

This script will:
1. Unlock LUKS encrypted device
2. Convert ext4 to Btrfs (non-destructive)
3. Create subvolumes (@, @home, @nix, @var_log, @snapshots)
4. Move data to subvolumes
5. Rebuild NixOS configuration

${YELLOW}IMPORTANT:${NC}
- Run this from a NixOS live ISO
- Backup critical data first
- Your ext4 will be preserved as ext2_saved for rollback
- This is a non-destructive process

EOF

    if ! confirm "Have you backed up critical data and are you ready to proceed"; then
        log_info "Migration cancelled"
        exit 0
    fi
    
    check_root
    check_live_iso
    identify_partitions
    unlock_luks
    convert_to_btrfs
    create_subvolumes
    move_data_to_subvolumes
    verify_migration
    
    if confirm "Rebuild NixOS now"; then
        rebuild_nixos
    else
        log_info "Skipping rebuild. You can rebuild manually later."
    fi
    
    log_success "Migration complete!"
    log_info "Next steps:"
    log_info "1. Reboot: sudo reboot"
    log_info "2. Verify: findmnt -t btrfs"
    log_info "3. List subvolumes: btrfs subvolume list /"
    log_info "4. After a few days, remove ext4 image: sudo btrfs-convert -i /dev/mapper/${LUKS_MAPPER}"
    
    if confirm "Reboot now"; then
        reboot
    fi
}

# Run main function
main "$@"

