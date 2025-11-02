# Standalone Home Manager Usage

This flake now uses **standalone Home Manager** configuration, separate from the NixOS system configuration.

## Configuration Structure

- **NixOS System Configuration**: `nixosConfigurations.alucard`
  - System-level packages and services
  - Located in `./machines/alucard/`
  
- **Home Manager Configuration**: `homeConfigurations."pixel-peeper@alucard"`
  - User-level packages and dotfiles
  - Located in `./homes/pixel-peeper/`

## Building and Switching

### Rebuild NixOS System

```bash
sudo nixos-rebuild switch --flake .#alucard
```

This only rebuilds the system configuration (boot, kernel, system services, etc.)

### Rebuild Home Manager

```bash
home-manager switch --flake .#pixel-peeper@alucard
```

This rebuilds your user environment (dotfiles, user packages, Hyprland config, etc.)

**Important:** After a fresh NixOS install or when home-manager is not yet installed, first run:

```bash
nix run home-manager/master -- switch --flake .#pixel-peeper@alucard
```

## Benefits of Standalone Home Manager

1. **Faster rebuilds**: User environment changes don't require sudo or system rebuild
2. **Independent updates**: Update user packages without touching system configuration
3. **Multi-user friendly**: Each user can manage their own configuration independently
4. **Rollback flexibility**: Separate generations for system and user environments

## Common Workflows

### After changing system configuration (e.g., kernel, boot settings)
```bash
sudo nixos-rebuild switch --flake .#alucard
```

### After changing user configuration (e.g., Hyprland, terminal, packages)
```bash
home-manager switch --flake .#pixel-peeper@alucard
```

### After changing both
```bash
sudo nixos-rebuild switch --flake .#alucard
home-manager switch --flake .#pixel-peeper@alucard
```

## Aliases

Consider adding these to your shell configuration:

```bash
alias nrs='sudo nixos-rebuild switch --flake /home/pixel-peeper/dotfiles#alucard'
alias hms='home-manager switch --flake /home/pixel-peeper/dotfiles#pixel-peeper@alucard'
```

## Troubleshooting

### Home Manager command not found
Install home-manager first:
```bash
nix run home-manager/master -- switch --flake .#pixel-peeper@alucard
```

### Conflicts with NixOS-managed files
This shouldn't happen with the standalone setup. If you encounter conflicts, ensure you're not managing the same files in both configurations.

### View Home Manager generations
```bash
home-manager generations
```

### Rollback Home Manager
```bash
home-manager generations  # Note the generation number
/nix/store/...-home-manager-generation  # Run the desired generation path
```

