# Editor Configurations

## Editors

| Editor | Package | Role |
|--------|---------|------|
| Cursor AI | `configs/editors/cursor.nix` (AppImage) | Primary IDE with AI/MCP |
| Zed | `pkgs.zed-editor` | Secondary editor |
| Neovim | `programs.neovim` (Lazy.nvim) | Terminal editor |

All three are installed via `homes/pixel-peeper/default.nix`.

---

## Cursor AI Editor

### Installation

Cursor is provided by a custom AppImage wrapper (`configs/editors/cursor.nix`) via Home Manager:

```nix
# configs/editors/cursor-config.nix — xdg.configFile."Cursor/argv.json"
{
  "disable-chromium-sandbox" = true;
  "password-store" = "gnome-libsecret";
}
```

Home Manager's `programs.cursor.argvSettings` writes to `~/.cursor/argv.json`, but Cursor reads `~/.config/Cursor/argv.json` — the config above targets the correct path.

The wrapper adds `libsecret`, disables Electron sandbox (so `sudo` works in the integrated terminal), and passes `--no-sandbox`.

### MCP (Model Context Protocol)

**Status:** Managed declaratively via `cursor-config.nix`.

**Configured MCP servers:**
- **NixOS** — package search, options, flake operations
- **GitKraken** — Git operations (via GitLens extension)

Secrets for remaining servers are encrypted with SOPS + Age in `secrets/users/pixel-peeper.yaml`.

The configuration deploys to `~/.cursor/mcp.json` on `home-manager switch`.

See [MCP-SETUP.md](../../MCP-SETUP.md) and [secrets/README.md](../../../secrets/README.md).

### Troubleshooting

**OS keyring error on Hyprland**  
Ensure `"password-store": "gnome-libsecret"` is set in `~/.config/Cursor/argv.json`. Gnome Keyring must be running (`systemctl --user status gnome-keyring`).

**Extensions misbehave in AppImage**  
The FHS wrapper in `cursor.nix` includes common runtime deps. If something still breaks, consider `pkgs.code-cursor-fhs` from nixpkgs as a fallback.

**Integrated terminal: sudo blocked**  
Expected fix: sandbox disabled via `argvSettings` and the `cursor.nix` wrapper.

---

## Zed Editor

Installed as `pkgs.zed-editor` alongside Cursor. No custom configuration yet — defaults only. Lightweight alternative for quick edits.
