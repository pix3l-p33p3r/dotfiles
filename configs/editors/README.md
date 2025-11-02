# Cursor Editor Configuration

AI-powered code editor built on VS Code, packaged as an AppImage for NixOS.

## Package

**Version**: 2.0.34  
**Type**: AppImage wrapped with Nix  
**Location**: `cursor.nix`

## Features

- VS Code fork with AI features built-in
- AI-powered code completion and chat
- Native Nix packaging with proper dependencies
- Desktop integration (icons, .desktop file)
- Update notifications disabled (managed by Nix)

## Configuration

**Package Definition**: `configs/editors/cursor.nix`  
**User Config**: `~/.config/Cursor/`  
**Extensions**: `~/.cursor/extensions/`

## Key Components

- **AppImage**: Downloaded from cursor.com
- **Dependencies**: xorg.libxshmfence, python3, gcc, gnumake, libsecret, libnotify
- **Desktop File**: Installed to `/share/applications`
- **Icons**: Installed to `/share/icons`

## Building

```bash
# Rebuild Home Manager to install/update
home-manager switch --flake .#pixel-peeper@alucard
```

## Updating Cursor

To update to a new version:

1. Update `version` in `cursor.nix`
2. Download new AppImage URL
3. Get new hash: `nix-prefetch-url <url>`
4. Update `sha256` hash
5. Rebuild Home Manager

## Notes

- Update notifications are disabled via `product.json`
- Managed declaratively through Nix
- No manual updates - use flake updates instead
