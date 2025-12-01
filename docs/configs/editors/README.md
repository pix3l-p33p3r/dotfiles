# Editor Configurations

## Cursor AI Editor

### Current Installation (`pkgs.code-cursor-fhs`)

On the `testing` branch Cursor is provided directly from **nixpkgs**:

```nix
home.packages = [
  pkgs.code-cursor-fhs
];

```

`code-cursor-fhs` ships upstream Cursor inside an FHS environment so the embedded browser, webviews, and VS Code extensions all work out of the box (no AppImage wrangling).

### Legacy Custom Package (still available)

`configs/editors/cursor.nix` remains in the repo in case we need to pin an AppImage manually:

To update that fallback package, repeat the AppImage steps below only if nixpkgs lags behind or the FHS build breaks.

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

