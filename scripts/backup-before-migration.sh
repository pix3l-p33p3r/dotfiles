#!/usr/bin/env bash
# Backup script for pre-migration safety
# Backs up critical and important files before Btrfs migration

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BACKUP_DEST="${BACKUP_DEST:-$HOME/backup-pre-migration-$(date +%Y%m%d-%H%M%S)}"
BACKUP_MODE="${BACKUP_MODE:-full}"  # 'minimal' or 'full'

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

# Critical files (always backed up)
CRITICAL_DIRS=(
    ".ssh"
    ".gnupg"
    ".task"
    ".timewarrior"
    "JoplinBackup"
)

# Important personal files (backed up in 'full' mode)
IMPORTANT_DIRS=(
    "Documents"
    "Pictures"
    "Videos"
    "Music"
    "Downloads"
)

# Configuration files (backed up in 'full' mode)
CONFIG_DIRS=(
    ".config/cursor"
    ".config/atuin"
)

create_backup() {
    local source_dir="$1"
    local dest_path="$2"
    
    if [[ ! -e "$HOME/$source_dir" ]]; then
        log_warning "$HOME/$source_dir not found, skipping"
        return 0
    fi
    
    log_info "Backing up $source_dir..."
    mkdir -p "$(dirname "$dest_path")"
    rsync -aHAX --info=progress2 "$HOME/$source_dir" "$dest_path" || {
        log_error "Failed to backup $source_dir"
        return 1
    }
}

main() {
    cat << EOF
${BLUE}
╔══════════════════════════════════════════════════════════════╗
║         Pre-Migration Backup Script                          ║
╚══════════════════════════════════════════════════════════════╝
${NC}

Backup destination: ${BACKUP_DEST}
Backup mode: ${BACKUP_MODE}

EOF

    # Create backup directory
    mkdir -p "$BACKUP_DEST"
    
    # Backup critical files
    log_info "Backing up CRITICAL files..."
    for dir in "${CRITICAL_DIRS[@]}"; do
        create_backup "$dir" "$BACKUP_DEST/$dir"
    done
    
    # Backup important files if in full mode
    if [[ "$BACKUP_MODE" == "full" ]]; then
        log_info "Backing up IMPORTANT files..."
        for dir in "${IMPORTANT_DIRS[@]}"; do
            create_backup "$dir" "$BACKUP_DEST/$dir"
        done
        
        log_info "Backing up CONFIGURATION files..."
        for dir in "${CONFIG_DIRS[@]}"; do
            create_backup "$dir" "$BACKUP_DEST/$dir"
        done
    else
        log_info "Skipping important files (use BACKUP_MODE=full for full backup)"
    fi
    
    # Create backup manifest
    log_info "Creating backup manifest..."
    {
        echo "Backup created: $(date)"
        echo "Backup mode: $BACKUP_MODE"
        echo "Backup location: $BACKUP_DEST"
        echo ""
        echo "Contents:"
        du -sh "$BACKUP_DEST"/* 2>/dev/null | sort -h
    } > "$BACKUP_DEST/BACKUP_MANIFEST.txt"
    
    log_success "Backup complete!"
    log_info "Backup location: $BACKUP_DEST"
    log_info "Manifest: $BACKUP_DEST/BACKUP_MANIFEST.txt"
    echo
    log_info "Backup size:"
    du -sh "$BACKUP_DEST"
    echo
    log_warning "IMPORTANT: Copy this backup to external storage before migration!"
}

# Run main function
main "$@"

