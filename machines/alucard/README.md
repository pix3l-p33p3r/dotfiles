<div align="center">
    <img alt="nixos" src="https://img.shields.io/badge/NixOS-Configuration-blue.svg?style=for-the-badge&labelColor=11111B&logo=nixos&logoColor=89B4FA&color=89B4FA">
    <img alt="hyprland" src="https://img.shields.io/badge/WM-Hyprland-purple.svg?style=for-the-badge&labelColor=11111B&logo=linux&logoColor=89B4FA&color=89B4FA">
    <img alt="modular" src="https://img.shields.io/badge/Architecture-Modular-green.svg?style=for-the-badge&labelColor=11111B&logo=hackerrank&logoColor=89B4FA&color=89B4FA">
</div>

<br>

# Machine Configuration Structure

Modular NixOS system configuration for alucard, organized for maintainability.

## Modules

```
alucard/
├── default.nix              # Entry point, imports all modules
├── hardware-configuration.nix  # Auto-generated hardware config
├── boot.nix                 # Secure Boot (Lanzaboote), Plymouth, firmware
├── system.nix               # Core settings, services
├── locale.nix               # Timezone, internationalization
├── users.nix                # User accounts, shell
├── programs.nix             # System programs
├── hardware-acceleration.nix # Intel drivers, VA-API, Vulkan, OpenCL
├── audio.nix                # Pipewire, ALSA
├── bluetooth.nix            # Bluetooth, Blueman
├── wayland.nix              # Hyprland (XWayland auto-enabled)
├── security.nix             # PAM, D-Bus, Dconf
├── docker.nix               # Docker container runtime
├── virt.nix                 # Virtualization (QEMU/KVM/libvirt)
└── maint.nix                # Auto-updates, GC, optimization
```

## Key Components

**System:** Secure Boot (Lanzaboote/UKI), Plymouth, LUKS, Intel microcode, HW acceleration, fwupd  
**Services:** NetworkManager, OpenSSH, UPower, Pipewire, Docker, QEMU/KVM/libvirt  
**Display:** Hyprland (Wayland), XWayland, Blueman

## Customization

**Add service:** Edit `system.nix` → `services.myservice.enable = true;`

**Create module:**
1. Create `machines/alucard/mymodule.nix`
2. Add to `default.nix` imports: `./mymodule.nix`

## Troubleshooting

```bash
nix flake check --show-trace        # Check for errors
nix-instantiate --eval ./default.nix # Validate module
sudo nixos-rebuild build --flake .#alucard  # Build without switching
```

**Firmware updates (fwupd):**
```bash
fwupdmgr get-updates    # Check available updates
sudo fwupdmgr update    # Apply updates
fwupdmgr get-devices    # Device status
```

**Secure Boot issues:**
```bash
sudo sbctl status       # Check status
sudo sbctl verify       # Verify boot entries
sudo bootctl status     # Boot loader status
sudo ~/dotfiles/scripts/cleanup-legacy-boot.sh  # Clean legacy entries
```

**Common issues:**
- Unsigned kernels in `/boot/EFI/nixos/`: Legacy entries, remove or sign
- Keys not enrolled: `sudo sbctl enroll-keys -m` after `sbctl create-keys`
- Rebuild after key enrollment: `sudo nixos-rebuild switch --flake .#alucard`

## Service Overview

| Service | Module | Config |
|---------|--------|--------|
| NetworkManager | `system.nix` | `networking.networkmanager.enable` |
| OpenSSH | `system.nix` | `services.openssh.enable` |
| Pipewire | `audio.nix` | Audio stack |
| Hyprland | `wayland.nix` | `programs.hyprland.enable` |
| fwupd | `boot.nix` | `services.fwupd.enable` |
| Docker | `docker.nix` | `virtualisation.docker.enable` |
| libvirt | `virt.nix` | `virtualisation.libvirtd.enable` |

## Benefits

- **Separation of Concerns** - Each module handles specific aspect
- **Easier Navigation** - Find settings by category
- **Better Maintainability** - Modify one area without affecting others
- **Cleaner Git History** - Targeted diffs

---

**See Also:**
- [PLYMOUTH-SETUP.md](PLYMOUTH-SETUP.md) - Boot splash configuration
- [HARDWARE-ACCELERATION.md](HARDWARE-ACCELERATION.md) - Intel GPU setup
- [CATPPUCCIN-SYSTEM.md](CATPPUCCIN-SYSTEM.md) - Theme configuration
