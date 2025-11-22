# Documentation Index

Complete navigation guide for NixOS dotfiles documentation.

## Core Documentation

**Getting Started:**
- [README.md](../README.md) - Repository overview, installation, quick start
- [HOME-MANAGER.md](HOME-MANAGER.md) - Standalone Home Manager guide

**Architecture & Decisions:**
- [DECISIONS.md](DECISIONS.md) - Core decisions (Git, Home Manager, Secrets, Nix optimizations)
- [DECISIONS-TOOLING.md](DECISIONS-TOOLING.md) - Tool choices (tmux, Taskwarrior, filesystem)

**Configuration Guides:**
- [MCP-SETUP.md](MCP-SETUP.md) - Model Context Protocol setup for Cursor AI (SOPS encryption)
- [SHORTCUTS.md](SHORTCUTS.md) - Keybinds and aliases reference
- [MIGRATE-EXT4-TO-BTRFS.md](MIGRATE-EXT4-TO-BTRFS.md) - Filesystem migration guide

**Security:**
- [secrets/README.md](../secrets/README.md) - SOPS + Age secrets management

## Component Documentation

**Desktop:**
- [configs/desktop/README.md](../configs/desktop/README.md) - Hyprland configuration

**Applications:**
- [configs/editors/README.md](../configs/editors/README.md) - Cursor AI editor setup
- [configs/terminal/nvim/README.md](../configs/terminal/nvim/README.md) - Neovim configuration
- [configs/terminal/zsh/README.md](../configs/terminal/zsh/README.md) - Zsh shell configuration

**System:**
- [machines/alucard/README.md](../machines/alucard/README.md) - Host-specific system configuration
- [machines/alucard/PLYMOUTH-SETUP.md](../machines/alucard/PLYMOUTH-SETUP.md) - Boot splash configuration
- [machines/alucard/HARDWARE-ACCELERATION.md](../machines/alucard/HARDWARE-ACCELERATION.md) - Intel GPU acceleration
- [machines/alucard/CATPPUCCIN-SYSTEM.md](../machines/alucard/CATPPUCCIN-SYSTEM.md) - Theme configuration
- [scripts/README.md](../scripts/README.md) - Utility scripts

## Quick Navigation

**Set up new machine:**
1. [README.md](../README.md) - Installation
2. [HOME-MANAGER.md](HOME-MANAGER.md) - Configure Home Manager

**Configure Cursor AI:**
1. [configs/editors/README.md](../configs/editors/README.md) - Editor setup
2. [MCP-SETUP.md](MCP-SETUP.md) - MCP capabilities

**Manage secrets:**
1. [secrets/README.md](../secrets/README.md) - SOPS encryption
2. [MCP-SETUP.md](MCP-SETUP.md#security) - Encrypted MCP secrets

**Customize desktop:**
1. [configs/desktop/README.md](../configs/desktop/README.md) - Hyprland
2. [machines/alucard/CATPPUCCIN-SYSTEM.md](../machines/alucard/CATPPUCCIN-SYSTEM.md) - Theming

**Understand architecture:**
1. [README.md](../README.md) - System overview
2. [DECISIONS.md](DECISIONS.md) - Configuration rationale

## Documentation Structure

```
docs/
├── INDEX.md                    # This file
├── DECISIONS.md                # Core decisions
├── DECISIONS-TOOLING.md        # Tool choices
├── HOME-MANAGER.md             # Home Manager guide
├── MCP-SETUP.md                # Cursor MCP setup
├── SHORTCUTS.md                # Keybinds reference
└── MIGRATE-EXT4-TO-BTRFS.md    # Filesystem migration

machines/alucard/
├── README.md                   # System configuration
├── PLYMOUTH-SETUP.md           # Boot splash
├── HARDWARE-ACCELERATION.md    # GPU acceleration
└── CATPPUCCIN-SYSTEM.md        # Theming

configs/
├── desktop/README.md            # Hyprland
├── editors/README.md            # Cursor
└── terminal/
    ├── nvim/README.md          # Neovim
    └── zsh/README.md            # Zsh

scripts/README.md                # Utility scripts
secrets/README.md               # Secrets management
```

## Search Tips

```bash
# Search all docs
grep -r "search-term" docs/

# Search config docs
grep -r "search-term" configs/*/README.md

# Find package mentions
grep -r "package-name" .
```

**Neovim Telescope:** `<leader>ff` (find files), `<leader>fg` (live grep), `<leader>fh` (help tags)

---

**Font Reference:** Code/Editor (JetBrainsMono Nerd Font), Terminal (FiraCode Nerd Font), UI (Cantarell)
