<div align="center">
    <img alt="nixos" src="https://img.shields.io/badge/NixOS-Configuration-blue.svg?style=for-the-badge&labelColor=11111B&logo=nixos&logoColor=89B4FA&color=89B4FA">
    <img alt="hyprland" src="https://img.shields.io/badge/WM-Hyprland-purple.svg?style=for-the-badge&labelColor=11111B&logo=linux&logoColor=89B4FA&color=89B4FA">
    <img alt="modular" src="https://img.shields.io/badge/Architecture-Modular-green.svg?style=for-the-badge&labelColor=11111B&logo=hackerrank&logoColor=89B4FA&color=89B4FA">
</div>

<br>

# Machine Configuration Structure

Modular NixOS system configuration for pixel-peeper, organized for maintainability and clarity.

## 📁 Modules

```
pixel-peeper/
├── default.nix              # Entry point, imports all modules
├── hardware-configuration.nix  # Auto-generated hardware config
├── boot.nix                 # Bootloader & Secure Boot (Lanzaboote)
├── system.nix               # Core settings, services
├── locale.nix               # Timezone, internationalization
├── users.nix                # User accounts, shell
├── programs.nix             # System programs (Firefox, nm-applet)
├── graphics.nix             # Intel drivers, VA-API, Vulkan
├── audio.nix                # Pipewire, ALSA
├── bluetooth.nix            # Bluetooth, Blueman
├── x11.nix                  # X11 compatibility
├── wayland.nix              # Hyprland window manager
├── security.nix             # PAM, D-Bus, Dconf
├── docker.nix               # Docker container runtime
├── virt.nix                 # Virtualization (QEMU/KVM/libvirt)
└── maint.nix                # Auto-updates, GC, optimization
```

## ⚙️ Key Components

**System**
- **Secure Boot**: Lanzaboote with UKI
- **Encryption**: LUKS disk encryption
- **CPU**: Intel with microcode updates
- **Graphics**: Intel integrated with VA-API hardware acceleration

**Services**
- **Networking**: NetworkManager, OpenSSH
- **Power**: UPower, power-profiles-daemon
- **Media**: Pipewire audio stack
- **Containers**: Docker, QEMU/KVM virtualization

**Display**
- **Wayland**: Hyprland compositor
- **X11**: Compatibility layer for legacy apps
- **Bluetooth**: Blueman manager

## 🔧 Customization

### Adding a Service

Add to `system.nix`:
```nix
services.myservice.enable = true;
```

### Creating a New Module

1. Create `machines/pixel-peeper/mymodule.nix`:
```nix
{ config, pkgs, ... }:
{
  # Your configuration here
}
```

2. Add to `default.nix` imports:
```nix
imports = [
  # ...
  ./mymodule.nix
];
```

## 🔍 Troubleshooting

```bash
# Check configuration for errors
nix flake check --show-trace

# Validate a module
nix-instantiate --eval ./default.nix

# Build without switching
sudo nixos-rebuild build --flake .#pixel-peeper
```

### Secure Boot Issues

If `sbctl verify` shows unsigned kernels:

```bash
# Check Secure Boot status
sudo sbctl status

# Verify all boot entries
sudo sbctl verify

# Check boot loader status
sudo bootctl status

# Clean up legacy boot entries (if using Lanzaboote)
sudo ~/dotfiles/scripts/cleanup-legacy-boot.sh
```

**Common Issues:**
- **Unsigned kernels in `/boot/EFI/nixos/`**: Legacy entries from pre-Lanzaboote setup. Remove or sign them.
- **Keys not enrolled**: Run `sudo sbctl enroll-keys -m` after `sbctl create-keys`
- **Rebuild after key enrollment**: `sudo nixos-rebuild switch --flake .#pixel-peeper`

## 📊 Service Overview

| Service | Module | Config |
|---------|--------|--------|
| NetworkManager | `system.nix` | `networking.networkmanager.enable` |
| OpenSSH | `system.nix` | `services.openssh.enable` |
| Pipewire | `audio.nix` | Audio stack |
| Hyprland | `wayland.nix` | `programs.hyprland.enable` |
| Docker | `docker.nix` | `virtualisation.docker.enable` |
| libvirt | `virt.nix` | `virtualisation.libvirtd.enable` |

## 💡 Benefits

- **Separation of Concerns** - Each module handles a specific aspect
- **Easier Navigation** - Find settings by category
- **Better Maintainability** - Modify one area without affecting others
- **Cleaner Git History** - Targeted diffs