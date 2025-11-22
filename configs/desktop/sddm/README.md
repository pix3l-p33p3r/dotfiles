# Custom SDDM Theme

This is a local copy of the [catppuccin-sddm-corners](https://github.com/khaneliman/catppuccin-sddm-corners) theme, which positions the input field (username/password) on the left side of the screen.

## Files

- `catppuccin/` - Theme files from the original repository
- `default.nix` - Nix derivation that builds the theme package

## Customization

You can customize the theme by editing files in `catppuccin/`:

### `theme.conf`

Main configuration file. Customize:
- **Background**: Path to wallpaper
- **Font**: Font family name (e.g., "JetBrainsMono Nerd Font")
- **Padding**: Distance from screen edges
- **CornerRadius**: Rounded corner radius
- **Colors**: All theme colors (text fields, buttons, popups, etc.)
- **Date/Time**: Format, size, opacity, bold settings
- **Input fields**: Colors, highlight colors, placeholder text
- **Buttons**: Login, session, power button colors and icons

### QML Files

Modify the layout and behavior:
- `Main.qml` - Main layout and structure
- `components/` - Individual UI components:
  - `LoginPanel.qml` - Login form layout
  - `UserFieldPanel.qml` - Username input field
  - `PasswordPanel.qml` - Password input field
  - `DateTimePanel.qml` - Date and time display
  - `PowerPanel.qml` - Power/suspend/reboot options
  - `SessionPanel.qml` - Session selection
  - `UserPanel.qml` - User selection

## Building

The theme is automatically built when you rebuild your NixOS configuration:

```bash
sudo nixos-rebuild switch --flake .#alucard
```

## References

- Original theme: https://github.com/khaneliman/catppuccin-sddm-corners
- Based on: https://github.com/aczv/sddm-theme-corners
- SDDM documentation: https://wiki.archlinux.org/title/SDDM

