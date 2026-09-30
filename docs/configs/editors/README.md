# Editor Configurations

## Editors

| Editor | Package | Role |
|--------|---------|------|
| Cursor AI | `configs/editors/cursor.nix` (official AppImage 3.17.21) | Primary IDE with AI/MCP |
| Antigravity | `configs/editors/antigravity.nix` (Hy4ri flake) | Google Antigravity hub/IDE/CLI |
| Codex Desktop | `configs/editors/codex-desktop.nix` (`ilysenko/codex-desktop-linux`) | ChatGPT / Codex GUI (official Linux .deb wrapped for Nix) |
| Zed | `pkgs.zed-editor` | Secondary editor |
| Neovim | `programs.neovim` (Lazy.nvim) | Terminal editor |

Installed via `homes/pixel-peeper/default.nix` (Codex Desktop also needs its Home Manager module from `flake.nix`).

---

## Cursor AI Editor

### Installation

Cursor is the official Linux AppImage from Cursor's CDN, wrapped with `appimageTools` (same pattern as Chrome: fetch the vendor binary, do not compile). Hydra does not cache unfree `pkgs.code-cursor`, so the nixpkgs derivation always rebuilds locally.

```nix
# configs/editors/cursor-config.nix — xdg.configFile."Cursor/argv.json"
{
  "disable-chromium-sandbox" = true;
  "password-store" = "gnome-libsecret";
}
```

Home Manager's `programs.cursor.argvSettings` writes to `~/.cursor/argv.json`, but Cursor reads `~/.config/Cursor/argv.json` — the config above targets the correct path.

Electron sandbox is disabled in `argv.json` so `sudo` works in the integrated terminal.

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

**Extensions misbehave**  
The FHS wrapper includes common runtime deps. If something still breaks, add the library to `extraPkgs` in `cursor.nix`.

**Integrated terminal: sudo blocked**  
Expected fix: sandbox disabled via `argv.json` (`disable-chromium-sandbox`).

---

## Zed Editor

Installed as `pkgs.zed-editor` alongside Cursor. No custom configuration yet — defaults only. Lightweight alternative for quick edits.
