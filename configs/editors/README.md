# Editor Configurations

## Cursor AI Editor

### Current Installation (Custom Package)

The configuration now installs Cursor version **2.0.34** using a custom Nix package that wraps the official AppImage:

```nix
home.packages = [
  (pkgs.callPackage ../../configs/editors/cursor.nix {})
];

```

This is defined in `cursor.nix` and provides proper desktop integration, icons, and application launcher entries.

### Updating to a Newer Version

To update Cursor to a newer version:

1. Find the new AppImage URL from the [Cursor website](https://cursor.com/download) or check their downloads page

2. Get the SHA256 hash:
```bash
nix-prefetch-url "https://downloads.cursor.com/production/COMMIT_HASH/linux/x64/Cursor-VERSION-x86_64.AppImage"
```

3. Update `configs/editors/cursor.nix`:
   - Change the `version` field
   - Update the `url` in the `fetchurl` block
   - Replace the `sha256` hash

4. Rebuild your configuration:
```bash
home-manager switch --flake .#pixel-peeper@alucard
```

### Alternative Installation Methods

#### Using nixpkgs (Older Version)

If you prefer the stable but older version (1.7.52) from nixpkgs:

```nix
home.packages = [
  pkgs.code-cursor
];
```

#### Using FHS Environment

For better extension compatibility with the nixpkgs version:

```nix
home.packages = [
  pkgs.code-cursor-fhs
];
```

### Features of Cursor

- **AI-Powered Completions**: Context-aware code suggestions
- **Chat**: Ask questions about your codebase
- **Composer**: AI-assisted code generation
- **VS Code Compatible**: All VS Code extensions work
- **Privacy**: Local processing option available

### Troubleshooting

**Issue**: Extensions don't work properly  
**Solution**: Use `code-cursor-fhs` instead of `code-cursor`

**Issue**: AppImage won't run  
**Solution**: Make sure you're using `appimage-run` and not executing directly

**Issue**: Can't download AppImage  
**Solution**: Check network connectivity or download from browser at https://cursor.com/download

