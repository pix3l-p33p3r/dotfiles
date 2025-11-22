<div align="center">
    <img alt="pixel-peeper avatar" src="./assets/avatar/ryuma.png" width="120px" />
</div>

<br>

# pixel-peeper's dotfiles

<br>
<div align="center">
    <a href="https://github.com/pix3l-p33p3r/dotfiles/stargazers">
        <img src="https://img.shields.io/github/stars/pix3l-p33p3r/dotfiles?color=89B4FA&labelColor=11111B&style=for-the-badge&logo=starship&logoColor=89B4FA">
    </a>
    <a href="https://github.com/pix3l-p33p3r/dotfiles/">
        <img src="https://img.shields.io/github/repo-size/pix3l-p33p3r/dotfiles?color=89B4FA&labelColor=11111B&style=for-the-badge&logo=github&logoColor=89B4FA">
    </a>
    <a href="https://nixos.org">
        <img src="https://img.shields.io/badge/NixOS-unstable-blue.svg?style=for-the-badge&labelColor=11111B&logo=NixOS&logoColor=89B4FA&color=89B4FA">
    </a>
    <a href="https://github.com/pix3l-p33p3r/dotfiles/blob/main/LICENSE">
        <img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=GPL-3.0&colorA=11111B&colorB=89B4FA&logo=gnu&logoColor=89B4FA"/>
    </a>
</div>
<br>

**Modern NixOS and Home Manager configuration** for a productive development environment. Hyprland-centric with comprehensive dev tools and Catppuccin Mocha theming.

## Installation

1. **Clone repository:**
```sh
git clone https://github.com/pix3l-p33p3r/dotfiles.git ~/.config/nixos
cd ~/.config/nixos
```

2. **Copy and customize host:**
   - Copy `machines/alucard` to match your hostname
   - Update `variables.nix`

3. **Add hardware config:**
```sh
sudo nixos-generate-config --show-hardware-config > machines/your-hostname/hardware-configuration.nix
```

4. **Update `flake.nix`:** Register new host under `nixosConfigurations`

5. **Build system:**
```sh
sudo nixos-rebuild switch --flake .#your-hostname
nix run home-manager/master -- switch --flake .#your-username@your-hostname
```

6. **Clean old generations (optional):**
```sh
./scripts/nix-cleaner.sh
```

> **Note:** Uses **standalone Home Manager**. See [docs/HOME-MANAGER.md](docs/HOME-MANAGER.md).

## Architecture

`machines/` (NixOS system) → `homes/` (Home Manager user) → `configs/` (apps) → `assets/`, `scripts/`, `secrets/`, `docs/`

## Keybindings

| Action | Keybind |
|--------|---------|
| Terminal | `Super + Return` |
| Launcher | `Super + D` |
| Kill window | `Super + Q` |
| Workspace | `Super + 1-9,0` |
| Move window | `Super + Shift + H/J/K/L` |
| Fullscreen | `Super + Shift + F` |
| Lock screen | `Super + Escape` |

See [docs/SHORTCUTS.md](docs/SHORTCUTS.md) for full list.

## Stack

**Desktop:** Hyprland, hyprpanel, rofi, hyprlock, hyprpaper  
**Terminal:** Kitty, Zsh (Zap), Neovim, tmux, yazi  
**Dev Tools:** LSP, TreeSitter, Copilot, lazygit, terraform, k9s  
**Security:** trivy, semgrep, nuclei, ffuf, vault, sops  
**Media:** MPV, Zathura, MPD, cava, imv

Package catalog: `configs/desktop/hyprland/core/pkgs.nix`

## Documentation

**Start here:** [docs/INDEX.md](docs/INDEX.md)

Quick links: [HOME-MANAGER.md](docs/HOME-MANAGER.md) | [System Config](machines/alucard/README.md) | [Desktop](configs/desktop/README.md) | [Secrets](secrets/README.md) | [Decisions](docs/DECISIONS.md)

## License

GNU General Public License v3.0 - see [LICENSE](LICENSE) file.

---

<div align="center">

**⭐ Star this repository if you found it helpful!**

Made with ❤️ by [pixel-peeper](https://pixel-peeper.me)

</div>
