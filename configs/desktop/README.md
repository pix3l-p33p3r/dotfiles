<div align="center">
    <img alt="hyprland" src="https://img.shields.io/badge/Hyprland-Wayland-purple.svg?style=for-the-badge&labelColor=11111B&logo=linux&logoColor=89B4FA&color=89B4FA">
    <img alt="wayland" src="https://img.shields.io/badge/Compositor-Hyprland-blue.svg?style=for-the-badge&labelColor=11111B&logo=wayland&logoColor=89B4FA&color=89B4FA">
    <img alt="catppuccin" src="https://img.shields.io/badge/Theme-Catppuccin-pink.svg?style=for-the-badge&labelColor=11111B&logo=github&logoColor=89B4FA&color=89B4FA">
</div>

<br>

# Desktop Configuration

Complete Hyprland desktop environment with Catppuccin theming and productivity tools.

## Structure

```
desktop/hyprland/
├── default.nix              # Main entry point
├── core/                    # Core configurations
│   ├── hyprland.nix         # Window manager
│   ├── keybindings.nix      # Keybindings
│   ├── settings.nix         # Window settings
│   ├── theming.nix          # GTK/Icon themes
│   ├── fonts.nix            # Font configuration
│   ├── pkgs.nix             # Package catalog
│   ├── services-config.nix  # User services
│   ├── submaps.nix          # Keybinding submaps
│   ├── variables.nix        # Environment variables
│   └── xdg.nix              # XDG configuration
└── apps/                    # Desktop applications
    ├── applets/             # Status bar, lockscreen, etc.
    │   ├── hyprpanel.nix    # Status bar
    │   ├── hyprlock.nix     # Lock screen
    │   ├── hypridle.nix     # Idle daemon
    │   ├── rofi.nix         # App launcher
    │   └── hyprpaper.nix    # Wallpaper daemon
    ├── battop.nix           # Battery monitor
    └── imv.nix              # Image viewer
```

## Features

**Hyprland Stack:** Dynamic tiling, hyprpanel (bar), hyprlock (secure lock), hypridle (idle), hyprpaper (wallpapers), Rofi launcher, hyprpicker/hyprshot utilities

**Theming:** Catppuccin Mocha, Papirus icons, Hyprcursor, Adw-gtk3 dark theme

**Fonts:** Code (JetBrainsMono Nerd Font), Terminal (FiraCode Nerd Font), UI (Noto Sans + CJK), Emoji (Noto Nerd Font), Fallbacks (Liberation, DejaVu)

**Wayland Tools:** wl-clipboard + cliphist, grim + slurp + grimblast, hyprpicker, zenity

## Keybindings

| Action | Keybind |
|--------|---------|
| Terminal | `Super + Return` |
| Launcher | `Super + D` |
| Run Dialog | `Super + Shift + D` |
| Kill Window | `Super + Q` |
| Workspace | `Super + 1-9,0` |
| Move Window | `Super + Shift + H/J/K/L` |
| Fullscreen | `Super + Shift + F` |
| Lock Screen | `Super + Escape` |
| Clipboard | `Super + Shift + V` |
| Color Picker | `Super + Shift + C` |

Full list: `core/keybindings.nix` | See also: [docs/SHORTCUTS.md](../../docs/SHORTCUTS.md)

## Packages

**Hyprland:** hyprland, hyprpanel, hyprlock, hypridle, hyprpaper, hyprpicker, hyprshot, hyprsunset, hyprutils, hyprcursor  
**Wayland Utils:** wl-clipboard, wl-clip-persist, grim, slurp, grimblast, cliphist, wl-color-picker  
**Development:** LSP, TreeSitter, Copilot, containers, K8s, security tools  
**Media:** MPV, Zathura, MPD, cava, imv

Full catalog: `core/pkgs.nix`

## Themes

All apps use **Catppuccin Mocha:** Terminal (Kitty, Tmux, Yazi), Development (LazyGit, GitUI), Media (MPV, IMV, Zathura, Cava), System (Btop, Bat, Eza, FZF), Launcher (Rofi)

## Customization

Edit: `core/keybindings.nix` (keybinds), `core/settings.nix` (settings), `core/theming.nix` (theme), `core/fonts.nix` (fonts), `core/pkgs.nix` (packages)

## Resources

- [Hyprland](https://hyprland.org/)
- [Catppuccin](https://github.com/catppuccin/catppuccin)
- [Rofi](https://github.com/davatorium/rofi)
