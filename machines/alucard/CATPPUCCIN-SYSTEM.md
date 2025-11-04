# Catppuccin System Theme Configuration

Complete Catppuccin Mocha theming across NixOS and Home Manager.

## 🎨 Theme Overview

**Flavor**: Catppuccin Mocha (Dark)
**Accent**: Lavender
**Consistency**: System-wide, from boot to desktop

## 🖥️ System Components (NixOS-level)

### Boot & System Services
Configured in `machines/alucard/system.nix`:
```nix
catppuccin.flavor = "mocha";
catppuccin.accent = "lavender";
```

### Plymouth Boot Splash
Configured in `machines/alucard/boot.nix`:
```nix
catppuccin.plymouth.enable = true;
catppuccin.plymouth.flavor = "mocha";
```

**Result**: Beautiful Catppuccin Mocha boot splash that matches your desktop!

## 🏠 User Applications (Home Manager-level)

Configured in `homes/pixel-peeper/catppuccin.nix`:

### Terminal & CLI Tools
- ✅ **Kitty** - Terminal emulator
- ✅ **Zsh** - Shell with syntax highlighting
- ✅ **Atuin** - Shell history
- ✅ **Btop** - System monitor
- ✅ **Bat** - Cat with syntax highlighting
- ✅ **Eza** - Modern ls
- ✅ **Fzf** - Fuzzy finder
- ✅ **Tmux** - Terminal multiplexer

### Development Tools
- ✅ **Lazygit** - Git TUI
- ✅ **K9s** - Kubernetes TUI

### Media & Documents
- ✅ **Zathura** - PDF viewer
- ✅ **MPV** - Media player
- ✅ **Imv** - Image viewer
- ✅ **Cava** - Audio visualizer

### Desktop Environment
- ✅ **Hyprland** - Window manager
- ✅ **Hyprlock** - Screen locker
- ✅ **Rofi** - Application launcher
- ✅ **Kvantum** - Qt theming

### Browsers & Communication
- ✅ **Qutebrowser** - Keyboard-driven browser
- ✅ **Librewolf** - Privacy browser
- ✅ **Vesktop** - Discord client

### System Integration
- ✅ **Cursors** - Mouse cursor theme
- ✅ **Cachix** - Binary cache enabled

## 🎨 Color Palette - Catppuccin Mocha

```
Base Colors:
- Rosewater: #f5e0dc
- Flamingo:  #f2cdcd
- Pink:      #f5c2e7
- Mauve:     #cba6f7
- Red:       #f38ba8
- Maroon:    #eba0ac
- Peach:     #fab387
- Yellow:    #f9e2af
- Green:     #a6e3a1
- Teal:      #94e2d5
- Sky:       #89dceb
- Sapphire:  #74c7ec
- Blue:      #89b4fa
- Lavender:  #b4befe (Your accent!)

Surface Colors:
- Base:      #1e1e2e (Background)
- Mantle:    #181825
- Crust:     #11111b

Text Colors:
- Text:      #cdd6f4
- Subtext1:  #bac2de
- Subtext0:  #a6adc8
```

## 🔄 Theming Hierarchy

```
Boot Level:
  └─ Plymouth (Catppuccin Mocha)
       ↓
System Level (NixOS):
  ├─ Global flavor: mocha
  ├─ Global accent: lavender
  └─ TTY colors (optional)
       ↓
User Level (Home Manager):
  ├─ Desktop Environment
  │   ├─ Hyprland
  │   ├─ Hyprlock
  │   ├─ Rofi
  │   └─ Kvantum (Qt apps)
  │
  ├─ Terminal Stack
  │   ├─ Kitty
  │   ├─ Zsh
  │   └─ CLI tools
  │
  └─ Applications
      ├─ Browsers
      ├─ Media players
      └─ Document viewers
```

## 🎯 Complete Boot-to-Desktop Flow

```
1. Power On
     ↓ [Catppuccin Mocha colors]
2. Plymouth Boot Splash
   - Mocha base background (#1e1e2e)
   - Lavender spinner (#b4befe)
   - Smooth animation
     ↓
3. Login Screen
   - Hyprland greeter (Mocha themed)
     ↓
4. Desktop Environment
   - Hyprland (Mocha)
   - Rofi (Mocha + Lavender)
   - Terminal (Kitty Mocha)
   - All apps themed consistently
```

## 🔧 Customization

### Change Accent Color

**System-wide:**
```nix
# machines/alucard/system.nix
catppuccin.accent = "mauve";  # or any other accent
```

**Home Manager:**
```nix
# homes/pixel-peeper/catppuccin.nix
catppuccin.accent = "mauve";
```

Available accents:
- `"rosewater"`, `"flamingo"`, `"pink"`, `"mauve"`
- `"red"`, `"maroon"`, `"peach"`, `"yellow"`
- `"green"`, `"teal"`, `"sky"`, `"sapphire"`
- `"blue"`, `"lavender"` ✅ (current)

### Change Flavor

Try different Catppuccin variants:

```nix
catppuccin.flavor = "latte";      # Light theme
catppuccin.flavor = "frappe";     # Dark theme (less contrast)
catppuccin.flavor = "macchiato";  # Dark theme (medium contrast)
catppuccin.flavor = "mocha";      # Dark theme (high contrast) ✅
```

### Enable TTY Theming

Make even your TTY (console) look beautiful:

```nix
# homes/pixel-peeper/catppuccin.nix
catppuccin.tty.enable = true;
```

## 🎨 Visual Consistency

Every part of your system now shares the same color palette:

| Component | Base | Accent | Status |
|-----------|------|--------|--------|
| Plymouth | #1e1e2e | #b4befe | ✅ |
| Hyprland | #1e1e2e | #b4befe | ✅ |
| Kitty | #1e1e2e | #b4befe | ✅ |
| Rofi | #1e1e2e | #b4befe | ✅ |
| Zathura | #1e1e2e | #b4befe | ✅ |
| MPV | #1e1e2e | #b4befe | ✅ |
| All apps | #1e1e2e | #b4befe | ✅ |

## 📊 Theme Coverage

**Boot to Desktop**: 100% themed
- [x] BIOS/UEFI (firmware default)
- [x] Plymouth boot splash
- [x] Login screen
- [x] Desktop environment
- [x] Window manager
- [x] Terminal
- [x] Applications
- [x] File manager (Thunar - GTK theme)
- [x] Document viewers
- [x] Media players
- [x] Browsers
- [x] Development tools

## 🔍 Verification

### Check Current Theme

**System-level:**
```bash
# No direct command, check config
cat /etc/nixos/configuration.nix | grep catppuccin
```

**Home Manager:**
```bash
home-manager packages | grep catppuccin
```

**Plymouth:**
```bash
plymouth-set-default-theme
# Should show: catppuccin-mocha
```

### Preview Colors

**Terminal test:**
```bash
# Show all Catppuccin colors
for color in {0..15}; do
  echo -en "\e[48;5;${color}m  ${color}  \e[0m "
  [ $((($color + 1) % 8)) -eq 0 ] && echo
done
```

## 🎁 Benefits

### Visual
- **Consistent** - Same colors everywhere
- **Beautiful** - Professional, modern design
- **Comfortable** - Easy on the eyes (Mocha dark theme)
- **Branded** - Recognizable, cohesive aesthetic

### Practical
- **Fast** - Declarative config, instant apply
- **Reproducible** - Same look on any machine
- **Maintainable** - Single source of truth
- **Cacheable** - Catppuccin Cachix for fast builds

### Developer Experience
- **Code clarity** - Syntax highlighting matches theme
- **Focus** - Reduced visual distraction
- **Professional** - Polished development environment

## 🔗 Resources

- [Catppuccin Website](https://catppuccin.com/)
- [Catppuccin NixOS Module](https://github.com/catppuccin/nix)
- [Color Palette](https://github.com/catppuccin/catppuccin)
- [Application Ports](https://github.com/catppuccin/catppuccin/blob/main/docs/ports.md)

---

**Status**: ✅ Fully Themed  
**Flavor**: Mocha (Dark)  
**Accent**: Lavender  
**Coverage**: System-wide (Boot → Desktop → Apps)

