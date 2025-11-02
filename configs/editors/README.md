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

### Updating Cursor

To update to a newer version:

1. Get the new AppImage URL from [Cursor downloads](https://cursor.com/download)
2. Fetch the SHA256 hash:
   ```bash
   nix-prefetch-url "https://downloads.cursor.com/production/COMMIT_HASH/linux/x64/Cursor-VERSION-x86_64.AppImage"
   ```
3. Update `cursor.nix`: version, url, and sha256
4. Rebuild: `hms` or `upgrade`

### MCP (Model Context Protocol) Configuration 🎯

**Status**: ✅ Managed declaratively via `cursor-config.nix` with SOPS-encrypted secrets

The MCP configuration is now fully declarative, version-controlled, and **security-hardened**:

```nix
# configs/editors/cursor-config.nix
home.file.".cursor/mcp.json" = {
  text = builtins.toJSON {
    mcpServers = { ... };
  };
};
```

**Configured MCP Servers**:
- **NixOS** - Package search, options, and flake operations (The Enlightened Way™)
- **Obsidian** - Second brain integration (API key encrypted with SOPS + Age)
- **GitKraken** - Git operations
- **Filesystem** - Dotfiles access

**Security Features**:
- 🔐 Obsidian API key encrypted with SOPS + Age
- 🔑 Secrets stored in `secrets/users/pixel-peeper.yaml` (encrypted)
- 🏗️ Automatic decryption during Home Manager build
- 📝 Age key location: `~/.config/sops/age/keys.txt`

The configuration automatically deploys to `~/.cursor/mcp.json` on `home-manager switch`.

See `docs/MCP-SETUP.md` for detailed documentation and `secrets/README.md` for SOPS usage.

### Features of Cursor

- **AI-Powered Completions**: Context-aware code suggestions
- **Chat**: Ask questions about your codebase
- **Composer**: AI-assisted code generation
- **MCP Integration**: Extended capabilities via Model Context Protocol
- **VS Code Compatible**: All VS Code extensions work
- **Privacy**: Local processing option available

### Troubleshooting

**Issue**: Extensions don't work properly  
**Solution**: Use `code-cursor-fhs` instead of `code-cursor`

**Issue**: AppImage won't run  
**Solution**: Make sure you're using `appimage-run` and not executing directly

**Issue**: Can't download AppImage  
**Solution**: Check network connectivity or download from browser at https://cursor.com/download

