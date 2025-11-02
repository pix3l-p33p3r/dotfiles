# Documentation Index

Complete guide to navigating the NixOS dotfiles documentation.

## 📚 Core Documentation

### Getting Started
- **[Main README](../README.md)** - Repository overview, installation, and quick start
- **[HOME-MANAGER.md](HOME-MANAGER.md)** - Standalone Home Manager configuration guide

### Configuration Guides
- **[MCP-SETUP.md](MCP-SETUP.md)** - Model Context Protocol setup for Cursor AI (with SOPS encryption)
- **[FONTS.md](FONTS.md)** - Font reference across different applications

### Architecture & Decisions
- **[DECISIONS.md](DECISIONS.md)** - Why Git over jj, why standalone Home Manager

### Security
- **[secrets/README.md](../secrets/README.md)** - SOPS + Age secrets management guide

---

## 📁 Component Documentation

### Desktop Environment
- **[configs/desktop/README.md](../configs/desktop/README.md)** - Hyprland window manager configuration

### Applications
- **[configs/editors/README.md](../configs/editors/README.md)** - Cursor AI editor setup
- **[configs/terminal/nvim/README.md](../configs/terminal/nvim/README.md)** - Neovim configuration
- **[configs/terminal/zsh/README.md](../configs/terminal/zsh/README.md)** - Zsh shell configuration

### System
- **[machines/alucard/README.md](../machines/alucard/README.md)** - Host-specific system configuration
- **[scripts/README.md](../scripts/README.md)** - Utility scripts documentation

---

## 🗺️ Quick Navigation

### I want to...

**Set up a new machine:**
1. [Main README](../README.md) - Installation guide
2. [HOME-MANAGER.md](HOME-MANAGER.md) - Configure Home Manager

**Configure Cursor AI:**
1. [configs/editors/README.md](../configs/editors/README.md) - Editor setup
2. [MCP-SETUP.md](MCP-SETUP.md) - Enable MCP capabilities
3. [CURSOR-UPDATE-FIX.md](CURSOR-UPDATE-FIX.md) - Disable update notifications

**Manage secrets:**
1. [secrets/README.md](../secrets/README.md) - SOPS encryption guide
2. [MCP-SETUP.md](MCP-SETUP.md#security) - Encrypted MCP secrets

**Customize my desktop:**
1. [configs/desktop/README.md](../configs/desktop/README.md) - Hyprland configuration
2. [FONTS.md](FONTS.md) - Font choices

**Understand the architecture:**
1. [DOCUMENTATION.md](DOCUMENTATION.md) - Complete system docs
2. [DECISIONS.md](DECISIONS.md) - Why things are configured this way

---

## 📖 Documentation Structure

```
docs/
├── INDEX.md                    # This file - navigation guide
├── DECISIONS.md                # Tooling decisions (Git, Home Manager)
├── HOME-MANAGER.md             # Standalone Home Manager guide
├── MCP-SETUP.md                # Cursor MCP setup + future ideas
└── FONTS.md                    # Font reference

configs/
├── desktop/README.md           # Hyprland setup
├── editors/README.md           # Cursor/editors
├── terminal/
│   ├── nvim/README.md          # Neovim configuration
│   └── zsh/README.md           # Zsh configuration

machines/alucard/README.md      # System configuration
scripts/README.md               # Utility scripts
secrets/README.md               # Secrets management
```

---

## 🔍 Search Tips

Use `grep` to search across documentation:

```bash
# Search all docs for a topic
grep -r "search-term" docs/

# Search configuration docs
grep -r "search-term" configs/*/README.md

# Find all mentions of a package
grep -r "package-name" .
```

Or use the built-in Neovim Telescope search:
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fh` - Help tags

---

**Last Updated**: 2025-11-02

