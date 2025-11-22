# Catppuccin System Theme Configuration

Complete Catppuccin Mocha theming across NixOS and Home Manager. System-wide consistency from boot to desktop.

## Configuration

**System (NixOS):** `machines/alucard/system.nix`
```nix
catppuccin.flavor = "mocha";
catppuccin.accent = "lavender";
```

**Plymouth:** `machines/alucard/boot.nix` (custom theme, see [PLYMOUTH-SETUP.md](PLYMOUTH-SETUP.md))

**User (Home Manager):** `homes/pixel-peeper/catppuccin.nix`

## Themed Components

**Terminal & CLI:** Kitty, Zsh, Atuin, Btop, Bat, Eza, Fzf, Tmux  
**Development:** Lazygit, K9s  
**Media:** Zathura, MPV, Imv, Cava  
**Desktop:** Hyprland, Hyprlock, Rofi, Kvantum  
**Browsers:** Qutebrowser, Librewolf, Vesktop  
**System:** Cursors, Cachix cache

## Customization

**Change accent:**
```nix
# System: machines/alucard/system.nix
# User: homes/pixel-peeper/catppuccin.nix
catppuccin.accent = "mauve";  # rosewater, flamingo, pink, mauve, red, maroon, peach, yellow, green, teal, sky, sapphire, blue, lavender
```

**Change flavor:**
```nix
catppuccin.flavor = "latte";      # Light
catppuccin.flavor = "frappe";     # Dark (less contrast)
catppuccin.flavor = "macchiato";  # Dark (medium contrast)
catppuccin.flavor = "mocha";      # Dark (high contrast) ✅
```

**Enable TTY theming:**
```nix
# homes/pixel-peeper/catppuccin.nix
catppuccin.tty.enable = true;
```

## Boot-to-Desktop Flow

```
Power On → Plymouth (Mocha) → Login (SDDM) → Desktop (Hyprland) → Apps (all themed)
```

All components share base `#1e1e2e` and accent `#b4befe` (lavender).

## Verification

```bash
# System config
grep -r "catppuccin" machines/alucard/system.nix

# Home Manager packages
home-manager packages | grep catppuccin

# Plymouth theme
plymouth-set-default-theme  # Should show: catppuccin-alucard
```

## Color Palette

Full palette: [catppuccin.com](https://catppuccin.com/palette)

**Key colors:**
- Base: `#1e1e2e` (background)
- Accent: `#b4befe` (lavender, current)
- Text: `#cdd6f4`

## Benefits

- **Consistent:** Same colors everywhere (boot → desktop → apps)
- **Reproducible:** Declarative config, same look on any machine
- **Fast:** Catppuccin Cachix for quick builds
- **Maintainable:** Single source of truth per layer

---

**See Also:**
- [PLYMOUTH-SETUP.md](PLYMOUTH-SETUP.md) - Custom Plymouth theme
- [Catppuccin NixOS Module](https://github.com/catppuccin/nix)
- [Color Palette Reference](https://catppuccin.com/palette)

**Status:** ✅ Fully Themed | **Flavor:** Mocha | **Accent:** Lavender
