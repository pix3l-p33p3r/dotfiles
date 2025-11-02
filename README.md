<div align="center">
    <img alt="pixel-peeper avatar" src="./assets/avatar/ryuma_pixel-peeper.png" width="120px" />
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

**A modern NixOS and Home Manager configuration** for a beautiful and productive
development environment. It provides a structured way to manage your system
with Hyprland, comprehensive dev tools, and consistent Catppuccin theming.

**Features:**

- 💻 Hyprland-centric: Preconfigured Hyprland ecosystem (hyprpanel, hyprlock, etc.)
- 🎨 Catppuccin Mocha: Consistent theming across desktop, terminal, and apps
- 🛠️ Dev Stack: LSP, TreeSitter, Copilot, containers, K8s, security tools
- ⌨️ Vim-like: Unified keybindings in Hyprland and Neovim

## 🚀 Installation

1. **Clone this repository:**

```sh
git clone https://github.com/pix3l-p33p3r/dotfiles.git ~/.config/nixos
cd ~/.config/nixos
```

2. **Copy and customize the host:**

Copy `machines/alucard` to match your hostname and update `variables.nix`.

3. **Add hardware configuration:**

Generate and copy your `hardware-configuration.nix` into your host folder:

```sh
sudo nixos-generate-config --show-hardware-config > machines/your-hostname/hardware-configuration.nix
```

4. **Update flake.nix:**

Register your new host under `nixosConfigurations`.

5. **Build the system:**

```sh
sudo nixos-rebuild switch --flake .#your-hostname
```

6. **Clean old generations (optional):**

```sh
./scripts/nix-cleaner.sh
```

## 🏗️ Architecture

```
dotfiles/
├── 🖥️ machines/              # NixOS system config
│   └── pixel-peeper/        # Host-specific config
├── 👤 homes/                 # Home Manager user config
│   └── pixel-peeper/        # User settings
├── 🎨 configs/              # Application configs
│   ├── desktop/hyprland/    # Hyprland + applets
│   ├── terminal/            # Neovim, Zsh, Kitty
│   ├── browsers/            # Firefox, Chromium
│   └── media/               # MPV, Zathura, MPD
├── 🖼️ assets/               # Wallpapers, avatars
└── 🔧 scripts/              # Utility scripts
```

## ⌨️ Keybindings

| Action | Keybind |
|--------|---------|
| Terminal | `Super + Return` |
| Launcher | `Super + D` |
| Kill window | `Super + Q` |
| Workspace | `Super + 1-9,0` |
| Move window | `Super + Shift + H/J/K/L` |
| Fullscreen | `Super + Shift + F` |
| Lock screen | `Super + Escape` |

See `configs/desktop/hyprland/core/keybindings.nix` for full list.

## 🛠️ Stack

**Desktop**: Hyprland, hyprpanel, rofi, hyprlock, hyprpaper  
**Terminal**: Kitty, Zsh (Zap), Neovim, tmux, yazi  
**Dev Tools**: LSP, TreeSitter, Copilot, lazygit, terraform, k9s  
**Security**: trivy, semgrep, nuclei, ffuf, vault, sops  
**Media**: MPV, Zathura, MPD, cava, imv  

Full package catalog in `configs/desktop/hyprland/core/pkgs.nix`.

## 📚 Documentation

- **Desktop**: [configs/desktop/README.md](configs/desktop/README.md) - Hyprland configuration
- **Neovim**: [configs/terminal/nvim/README.md](configs/terminal/nvim/README.md) - Editor setup
- **Zsh**: [configs/terminal/zsh/README.md](configs/terminal/zsh/README.md) - Shell configuration
- **Machine**: [machines/alucard/README.md](machines/alucard/README.md) - NixOS system config

## 📄 License

GNU General Public License v3.0 - see [LICENSE](LICENSE) file.

---

<div align="center">

**⭐ Star this repository if you found it helpful!**

Made with ❤️ by [pixel-peeper](https://pixel-peeper.me)

</div>