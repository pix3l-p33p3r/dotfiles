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
├── boot.nix                 # Secure Boot (Lanzaboote), Plymouth, TPM2, firmware
├── system.nix               # Core settings, hostname, NetworkManager, sysctls
├── locale.nix               # Timezone, internationalization
├── users.nix                # User accounts, shell, groups
├── programs.nix             # System programs
├── hardware-acceleration.nix # Intel drivers, VA-API, Vulkan, OpenCL
├── graphics.nix             # Intel Mesa, GPU config
├── audio.nix                # Pipewire, ALSA
├── bluetooth.nix            # Bluez, Blueman
├── power.nix                # TLP, intel_pstate powersave governor
├── swap.nix                 # zram swap configuration
├── wayland.nix              # Hyprland (XWayland auto-enabled)
├── display-manager.nix      # SDDM display manager
├── security.nix             # PAM, AppArmor, OpenSSH hardening, D-Bus
├── firewall.nix             # nftables firewall + network hardening sysctls
├── clamav.nix               # ClamAV daemon, freshclam, daily scan timer
├── secrets.nix              # SOPS/Age key paths
├── docker.nix               # Docker container runtime
├── virt.nix                 # QEMU/KVM/libvirt (socket-activated)
├── vpn.nix                  # IPsec VPN (strongSwan)
├── dns.nix                  # DNS configuration
└── maint.nix                # Auto-updates, GC, optimization
```

## Key Components

**Boot:** Secure Boot (Lanzaboote/UKI), Plymouth (Catppuccin), LUKS + TPM2 auto-unlock, Intel microcode, fwupd  
**Hardware:** Intel VA-API, Vulkan, OpenCL, Mesa, intel_pstate powersave governor  
**Services:** NetworkManager, OpenSSH, UPower, Pipewire, Docker, QEMU/KVM/libvirt (socket-activated)  
**Display:** SDDM, Hyprland (Wayland), XWayland, Blueman  
**Security:** SOPS/Age secrets, PAM, AppArmor, nftables firewall, ClamAV, OpenSSH hardening

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
- Rebuild after key enrollment: `sudo nixos-rebuild switch --flake '.#alucard'`
- TPM2 unlock breaks after BIOS update: re-enroll with `systemd-cryptenroll` (see [TPM2-LUKS.md](TPM2-LUKS.md))

## Service Overview

| Service | Module | Config |
|---------|--------|--------|
| Lanzaboote | `boot.nix` | Secure Boot UKI signing |
| Plymouth | `boot.nix` | Catppuccin boot splash |
| fwupd | `boot.nix` | `services.fwupd.enable` |
| NetworkManager | `system.nix` | `networking.networkmanager.enable` |
| OpenSSH | `system.nix` | `services.openssh.enable` |
| SDDM | `display-manager.nix` | Display manager |
| Pipewire | `audio.nix` | Audio stack |
| Bluetooth | `bluetooth.nix` | Bluez + Blueman |
| Hyprland | `wayland.nix` | `programs.hyprland.enable` |
| Intel GPU | `hardware-acceleration.nix` | VA-API, Vulkan, OpenCL |
| TLP | `power.nix` | `intel_pstate` powersave governor |
| zram | `swap.nix` | Compressed swap in RAM |
| Docker | `docker.nix` | `virtualisation.docker.enable` |
| libvirt | `virt.nix` | `virtualisation.libvirtd.enable` (socket-activated) |
| SOPS | `secrets.nix` | Age key paths for secret decryption |
| nftables firewall | `firewall.nix` | Default-deny, stealth drop, network sysctls |
| AppArmor | `security.nix` | LSM, community profiles, non-killing mode |
| ClamAV | `clamav.nix` | clamd + freshclam + daily scan at 03:00 |

## Benefits

- **Separation of Concerns** - Each module handles specific aspect
- **Easier Navigation** - Find settings by category
- **Better Maintainability** - Modify one area without affecting others
- **Cleaner Git History** - Targeted diffs

---

**See Also:**
- [PLYMOUTH-SETUP.md](PLYMOUTH-SETUP.md) - Boot splash configuration
- [TPM2-LUKS.md](TPM2-LUKS.md) - TPM2 LUKS auto-unlock setup
- [SECURITY.md](SECURITY.md) - AppArmor, firewall, ClamAV
- [HARDWARE-ACCELERATION.md](HARDWARE-ACCELERATION.md) - Intel GPU setup
- [CATPPUCCIN-SYSTEM.md](CATPPUCCIN-SYSTEM.md) - Theme configuration
