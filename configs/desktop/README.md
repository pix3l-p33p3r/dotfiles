# Desktop Configuration

Complete Hyprland desktop environment with Catppuccin theming.

## Structure

```
desktop/hyprland/
├── default.nix          # Main entry point
├── core/                # Core configurations
│   ├── hyprland.nix     # Window manager
│   ├── keybindings.nix  # Keybindings
│   ├── settings.nix     # Window settings
│   ├── theming.nix      # GTK/Icon themes
│   ├── fonts.nix        # Font configuration
│   └── pkgs.nix         # Package catalog
└── apps/                # Desktop applications
    └── applets/         # Bar, lockscreen, etc.
```

## Features

**Hyprland Stack**
- Dynamic tiling with animations
- hyprpanel (bar), hyprlock (lock), hypridle (idle), hyprpaper (wallpapers)
- Rofi launcher with Catppuccin theme

**Theming**
- Catppuccin Mocha everywhere
- Papirus icons with Catppuccin
- Adw-gtk3 dark theme

**Fonts**
- Code: JetBrainsMono Nerd Font
- Terminal: FiraCode Nerd Font
- UI: Noto Sans with CJK support

## Essential Keybindings

| Action | Keybind |
|--------|---------|
| Terminal | `Super + Return` |
| Launcher | `Super + D` |
| Kill Window | `Super + Q` |
| Workspace 1-9 | `Super + 1-9` |
| Lock Screen | `Super + Escape` |

See `core/keybindings.nix` for full list.

## Customization

Edit configuration files in `core/`:
- Keybindings: `keybindings.nix`
- Settings: `settings.nix`
- Theme: `theming.nix`
- Packages: `pkgs.nix`
