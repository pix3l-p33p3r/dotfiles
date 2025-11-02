# Machine Configuration: alucard

Modular NixOS system configuration organized by concern.

## Modules

```
alucard/
├── default.nix              # Entry point, imports all
├── hardware-configuration.nix  # Auto-generated hardware
├── boot.nix                 # Bootloader & Secure Boot
├── system.nix               # Core settings & services
├── locale.nix               # Timezone & i18n
├── users.nix                # User accounts
├── programs.nix             # System programs
├── graphics.nix             # Intel drivers & VA-API
├── audio.nix                # Pipewire
├── bluetooth.nix            # Bluetooth & Blueman
├── wayland.nix              # Hyprland
├── security.nix             # PAM & D-Bus
├── docker.nix               # Docker runtime
├── virt.nix                 # QEMU/KVM
└── maint.nix                # Auto-updates & GC
```

## Key Components

**System**
- Secure Boot: Lanzaboote with UKI
- LUKS encryption
- Intel CPU with microcode
- Firmware updates via fwupd

**Services**
- NetworkManager, OpenSSH
- Pipewire audio
- Docker & QEMU/KVM
- Power management

## Customization

**Add a service** - Edit `system.nix`:
```nix
services.myservice.enable = true;
```

**Create new module** - Create file, add to `default.nix` imports

## Troubleshooting

```bash
# Check configuration
nix flake check --show-trace

# Build without switching
sudo nixos-rebuild build --flake .#alucard

# Check firmware updates
fwupdmgr get-updates
```
