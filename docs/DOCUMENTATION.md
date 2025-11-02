# Documentation

Complete documentation for NixOS dotfiles configuration, tooling decisions, and secrets management.

## Table of Contents

- [Tooling Decisions](#tooling-decisions)
  - [Git vs Jujutsu (jj)](#git-vs-jujutsu-jj)
  - [Standalone vs Integrated Home Manager](#standalone-vs-integrated-home-manager)
- [Home Manager Usage](#home-manager-usage)
- [Secrets Management](#secrets-management)
- [Font Reference](#font-reference)

---

## Tooling Decisions

This section records key decisions about tools and technologies used (or not used) in this dotfiles configuration, along with the reasoning behind each choice.

### Git vs Jujutsu (jj)

#### The Question

I evaluated whether to add `jj` (Jujutsu), a modern Git-compatible version control system, to my development setup. After careful consideration, I decided to stick with Git.

#### What is jj?

`jj` (Jujutsu) is a Git-compatible version control system that aims to improve upon Git's workflow with:

- **Better conflict handling** - Superior merge conflict detection and resolution
- **Automatic snapshotting** - No need to commit before switching branches
- **Performance improvements** - Faster operations on large repositories
- **Git compatibility** - Can work alongside Git and push to Git remotes

#### My Current Setup

I'm currently using:
- **Git** with standard tooling (`git`, `git-lfs`, `git-crypt`, `git-secrets`)
- **GitHub/GitLab CLIs** (`gh`, `glab`) for workflow automation
- **lazygit** for a TUI interface when I need visual git operations
- **Neovim Git plugins** (`gitsigns`) that integrate with Git

This setup works well for my needs, especially for managing my NixOS dotfiles repository.

#### ROI Analysis

**For My Dotfiles Repository: Low to Negative**

My dotfiles repository is relatively small and well-structured. Git handles it perfectly fine:
- Small repository size means Git's performance is already excellent
- Infrequent conflicts due to solo development
- Simple branching strategy
- The time investment to learn `jj` wouldn't provide meaningful benefits here

**For Larger/Team Projects: Medium to High**

If I were working on large monorepos or frequently dealing with complex merge conflicts, `jj` might offer better value. However, that's not my current use case.

#### Pros of jj

1. **Better Conflict Handling** - Superior merge conflict detection and resolution
2. **Automatic Snapshots** - No need to commit before switching branches
3. **Performance** - Faster on very large repositories (10k+ files)
4. **Git Compatibility** - Can coexist with Git workflows
5. **Modern UX** - Better CLI output and more intuitive commands

#### Cons of jj

1. **Learning Curve** - New commands and mental model to learn
2. **Ecosystem Incompatibility** - `lazygit`, Neovim plugins, CI/CD expect Git
3. **Team Collaboration** - Others would need to learn `jj`
4. **NixOS/Nix Ecosystem** - Most Nix configurations assume Git
5. **Maturity** - Newer tool with smaller community
6. **Maintenance Overhead** - Would need to maintain knowledge of both tools

#### My Decision

**I'm not adding jj to my setup.**

For my NixOS dotfiles repository specifically:
- Small, manageable repository - Git handles it perfectly
- Solo development - No complex merge conflicts
- Existing Git workflow works well
- Nix/Flakes ecosystem expects Git

The learning curve and ecosystem incompatibilities outweigh the potential benefits for my use case.

#### When I Might Reconsider

I would consider adding `jj` if:
- I start working on large monorepos with 10k+ files regularly
- I frequently encounter complex merge conflicts
- I work with teams that have adopted `jj`
- `jj` gains broader ecosystem support (especially Neovim and lazygit)

---

### Standalone vs Integrated Home Manager

#### The Question

When setting up my NixOS configuration, I had to decide between two approaches for managing my user environment with Home Manager: integrated (as a NixOS module) or standalone (separate from the system configuration). I chose standalone.

#### What's the Difference?

**Integrated Home Manager** runs as part of your NixOS system configuration. You rebuild everything together with one command:
```bash
sudo nixos-rebuild switch --flake .#alucard
```

**Standalone Home Manager** is completely separate from your NixOS system. You rebuild them independently:
```bash
sudo nixos-rebuild switch --flake .#alucard  # System only
home-manager switch --flake .#pixel-peeper@alucard  # User environment only
```

#### My Current Setup

I'm using standalone Home Manager with:
- **NixOS system config** (`nixosConfigurations.alucard`) managing kernel, drivers, system services, and boot configuration
- **Home Manager config** (`homeConfigurations."pixel-peeper@alucard"`) managing dotfiles, user packages, Hyprland, terminal setup, and applications
- **Shell aliases** (`nrs` and `hms`) to make rebuilding quick and easy
- **Combined `upgrade` alias** that updates flake, rebuilds both, and cleans up

This separation gives me the flexibility to iterate quickly on my desktop and terminal configuration without touching the system.

#### ROI Analysis

**For My Use Case: High**

I'm constantly tweaking my Hyprland setup, Neovim config, terminal settings, and application preferences. With standalone Home Manager:
- Rebuilds take ~30 seconds instead of 5+ minutes
- No sudo needed for most of my daily changes
- I can experiment freely without risking system stability
- Fast iteration means I actually enjoy refining my setup

**For Set-and-Forget Configs: Low to Negative**

If I rarely changed my configuration (like on a stable server), the integrated approach would be simpler. But that's not how I use my dotfiles - they're constantly evolving.

#### Pros of Standalone Home Manager

1. **Blazing Fast User Updates** - Tweaking my config rebuilds in seconds, not minutes
2. **No Sudo for User Changes** - Can rebuild user environment without root privileges
3. **Independent Rollbacks** - If I break my setup, I can roll back just the user environment
4. **Better Mental Model** - Clear separation between system stuff and user stuff
5. **Safer Experimentation** - Breaking user environment doesn't affect the system
6. **Future-Proof for Multi-User** - Each user can manage their own config independently
7. **Cleaner Generation History** - User environment changes separate from system changes

#### Cons of Standalone Home Manager

1. **Two Commands Instead of One** - Need to run both `nrs` and `hms`
2. **Initial Setup Hurdle** - First time requires `nix run home-manager/master -- switch`
3. **Coordination Required** - When updating flake, need to rebuild both
4. **Potential Version Drift** - System and user configs could end up on different nixpkgs versions
5. **"Where Does This Go?" Confusion** - Sometimes unclear if package goes in system or Home Manager
6. **Two Places to Debug** - Need to figure out if issue is system or Home Manager
7. **Less Common Pattern** - Most tutorials show integrated Home Manager

#### My Decision

**I'm using standalone Home Manager.**

Here's why this works for me:
- I'm actively developing my config - tweaking Hyprland, Neovim, and terminal settings multiple times per week
- Fast iteration is valuable - 30-second rebuilds vs 5-minute rebuilds makes me more likely to experiment
- Clear separation helps - I know exactly where system stuff lives vs user stuff
- No sudo for daily work - Most of my changes are user-level
- My aliases handle complexity - `nrs`, `hms`, and `upgrade` make the workflow painless

The speed benefit alone is worth it. When fine-tuning my Hyprland layout or testing a new Neovim plugin, waiting 5+ minutes for a full system rebuild kills the flow. With standalone, I make a change, run `hms`, and I'm back to work in 30 seconds.

#### When I Might Reconsider

I would switch back to integrated Home Manager if:
- I stop actively developing my config and just want set-and-forget simplicity
- I'm setting up a server where I rarely change user config
- I want the absolute simplest possible setup for someone else to maintain
- The coordination overhead starts causing real problems (hasn't happened yet)

For an actively maintained, constantly evolving dotfiles repository like mine, standalone is the clear winner.

---

## Home Manager Usage

This flake uses **standalone Home Manager** configuration, separate from the NixOS system configuration.

### Configuration Structure

- **NixOS System Configuration**: `nixosConfigurations.alucard`
  - System-level packages and services
  - Located in `./machines/alucard/`
  
- **Home Manager Configuration**: `homeConfigurations."pixel-peeper@alucard"`
  - User-level packages and dotfiles
  - Located in `./homes/pixel-peeper/`

### Building and Switching

#### Rebuild NixOS System

```bash
sudo nixos-rebuild switch --flake .#alucard
```

This only rebuilds the system configuration (boot, kernel, system services, etc.)

#### Rebuild Home Manager

```bash
home-manager switch --flake .#pixel-peeper@alucard
```

This rebuilds your user environment (dotfiles, user packages, Hyprland config, etc.)

**Important:** After a fresh NixOS install or when home-manager is not yet installed, first run:

```bash
nix run home-manager/master -- switch --flake .#pixel-peeper@alucard
```

### Benefits of Standalone Home Manager

1. **Faster rebuilds** - User environment changes don't require sudo or system rebuild
2. **Independent updates** - Update user packages without touching system configuration
3. **Multi-user friendly** - Each user can manage their own configuration independently
4. **Rollback flexibility** - Separate generations for system and user environments

### Common Workflows

**After changing system configuration (e.g., kernel, boot settings):**
```bash
sudo nixos-rebuild switch --flake .#alucard
```

**After changing user configuration (e.g., Hyprland, terminal, packages):**
```bash
home-manager switch --flake .#pixel-peeper@alucard
```

**After changing both:**
```bash
sudo nixos-rebuild switch --flake .#alucard
home-manager switch --flake .#pixel-peeper@alucard
```

### Aliases

Consider adding these to your shell configuration:

```bash
alias nrs='sudo nixos-rebuild switch --flake /home/pixel-peeper/dotfiles#alucard'
alias hms='home-manager switch --flake /home/pixel-peeper/dotfiles#pixel-peeper@alucard'
```

### Troubleshooting

**Home Manager command not found:**
```bash
nix run home-manager/master -- switch --flake .#pixel-peeper@alucard
```

**View Home Manager generations:**
```bash
home-manager generations
```

**Rollback Home Manager:**
```bash
home-manager generations  # Note the generation number
/nix/store/...-home-manager-generation  # Run the desired generation path
```

---

## Secrets Management

This repository uses SOPS (Secrets Operations) integrated with Age encryption for managing secrets in NixOS configuration.

### Overview

- **SOPS** - YAML/JSON file encryption with key management
- **Age** - Modern, simple, secure encryption tool
- **sops-nix** - NixOS integration for automatic secret decryption during builds

### Directory Structure

```
secrets/
├── .sops.yaml          # SOPS configuration
├── hosts/              # Host-level secrets (NixOS)
│   └── alucard.yaml
└── users/              # User-level secrets (Home Manager)
    └── pixel-peeper.yaml
```

### Key Files

**Age Key:**
- **Location**: `~/.config/sops/age/keys.txt`
- **Public Key**: `age1zln4nlxttpqehayq4wmve2fcvl80zs2mt0xyh5c7ur56hvztdvdqsnv362`
- **⚠️ NEVER commit this file to git**

**Configuration:**
- `secrets/.sops.yaml` - SOPS rules for encryption
- `machines/alucard/secrets.nix` - NixOS SOPS integration

### Quick Start

#### Edit a Secret

```bash
# Edit host secrets (auto-decrypts/encrypts)
sops secrets/hosts/alucard.yaml

# Edit user secrets
sops secrets/users/pixel-peeper.yaml
```

#### Add Your First Real Secret

1. Edit the secret file:
   ```bash
   sops secrets/hosts/alucard.yaml
   ```

2. Replace placeholder:
   ```yaml
   github_token: "ghp_your_real_token_here"
   ssh_host_key: |
     -----BEGIN OPENSSH PRIVATE KEY-----
     ...
   ```

3. Save - SOPS auto-encrypts

4. Use in NixOS (`machines/alucard/secrets.nix`):
   ```nix
   sops.secrets."github_token" = {
     owner = config.users.users.pixel-peeper.name;
     mode = "0400";
   };
   ```

5. Reference in config:
   ```nix
   environment.variables.GITHUB_TOKEN = config.sops.secrets."github_token".path;
   ```

#### Rebuild with Secrets

```bash
# Secrets are automatically decrypted during rebuild
sudo nixos-rebuild switch --flake .#alucard
```

Secrets are decrypted to `/run/secrets/` at boot/rebuild time.

### Security Status

✅ **Installed**: `age`, `sops`, `sops-nix`  
✅ **Configured**: Flake input, module, age key  
✅ **Encrypted**: All example secret files  
✅ **Protected**: Age keys in `.gitignore`

### Important Notes

- **Age key is in `.gitignore`** - Never commit `~/.config/sops/age/keys.txt`
- **Encrypted files are safe to commit** - They're encrypted with your age key
- **Lose the key = lose the secrets** - Keep backups offline
- **Decryption happens at build time** - No manual steps needed

### Key Management

**Backup your age key:**
```bash
cp ~/.config/sops/age/keys.txt ~/backups/
```

**Restore on new machine:**
```bash
mkdir -p ~/.config/sops/age
cp ~/backups/keys.txt ~/.config/sops/age/keys.txt
```

### Basic Operations

**Encrypt a file:**
```bash
sops -e -i secrets/hosts/alucard.yaml
```

**Decrypt to stdout:**
```bash
sops -d secrets/hosts/alucard.yaml
```

**Edit encrypted file:**
```bash
sops secrets/hosts/alucard.yaml
```

### Troubleshooting

**"No decryption key available"**  
→ Check `~/.config/sops/age/keys.txt` exists

**"Failed to decrypt with age"**  
→ Verify public key in `secrets/.sops.yaml` matches your key

**"Permission denied" at rebuild**  
→ Check owner/mode in `secrets.nix` match your config

---

## Font Reference

Quick reference for fonts used across different contexts.

| Context | Font | Config |
|---------|------|--------|
| Code Editor (Neovim/VS Code) | JetBrainsMono Nerd Font | `~/.config/nvim/init.lua` |
| Terminal (Kitty) | FiraCode Nerd Font | `~/.config/kitty/kitty.conf` |
| Obsidian | Iosevka Nerd Font | `~/.obsidian/snippets/fonts.css` |
| Web/Blog | Noto Sans | `styles.css` |
| Docs | Noto Serif | LibreOffice/LaTeX |
| UI (GTK) | Cantarell | `~/.config/gtk-3.0/settings.ini` |

**Common Sizes:**
- Code: 12-14pt
- Terminal: 11-13pt
- Readable text: 14-16pt
- Web body: 16-18px

---

*Last updated: November 2025*

