# Neovim Configuration

Modern Neovim setup with LSP, Treesitter, and GitHub Copilot.

## ✨ Features

- **Plugin Manager**: Lazy.nvim
- **Theme**: Catppuccin Mocha
- **LSP**: TypeScript, Python, Rust, Go, C/C++, Lua, Nix
- **Completion**: Native LSP completion
- **AI**: GitHub Copilot
- **Git**: GitSigns integration
- **File Explorer**: Neo-tree, Oil.nvim
- **Fuzzy Finding**: Telescope
- **Navigation**: Leap (quick movement)
- **Formatting**: Conform with Prettier, Black, Stylua, Rustfmt, Nixfmt
- **Auto-save**: Enabled by default

## 📁 Structure

```
nvim/
├── default.nix              # Nix config with LSP servers
└── conf/
    ├── init.lua             # Entry point
    ├── lua/
    │   ├── config/          # Core settings
    │   │   ├── lazy.lua     # Plugin manager
    │   │   ├── lsp.lua      # LSP config
    │   │   └── options.lua  # Neovim options
    │   └── plugins/         # Plugin configurations
    │       ├── telescope.lua
    │       ├── neo-tree.lua
    │       ├── copilot.lua
    │       ├── gitsigns.lua
    │       └── ... (30+ plugins)
    └── plugin/keymaps/      # Keybindings
```

## ⌨️ Key Bindings

| Mode | Key | Action |
|------|-----|--------|
| Normal | `<leader>ff` | Find files |
| Normal | `<leader>fg` | Live grep |
| Normal | `<leader>fb` | Browse buffers |
| Normal | `<leader>e` | Toggle file explorer |
| Normal | `gd` | Go to definition |
| Normal | `gr` | Show references |
| Normal | `K` | Hover documentation |
| Normal | `<leader>ca` | Code actions |
| Normal | `s` | Leap forward |
| Normal | `S` | Leap backward |
| Insert | `<C-Space>` | Trigger completion |

**Leader key**: `Space`

## 🔧 LSP Servers (via Nix)

Configured in `default.nix`:
- TypeScript/JavaScript: `typescript-language-server`, `vtsls`
- Python: `pyright`, `ruff`
- Rust: `rust-analyzer`
- Go: `gopls`
- C/C++: `clangd`
- Lua: `lua-language-server`
- Nix: `nil`, `nixd`
- Shell: `bash-language-server`
- YAML: `yaml-language-server`
- Markdown: `marksman`

## 🎨 Customization

### Add a plugin

Edit `conf/lua/plugins/yourplugin.lua`:

```lua
return {
  "author/plugin-name",
  config = function()
    require("plugin-name").setup({})
  end,
}
```

### Change colorscheme

Edit `conf/lua/plugins/catppuccin.lua` or replace with another theme plugin.

### Modify keybindings

Edit files in `conf/plugin/keymaps/`.

## 📦 Installation

Managed by Home Manager via `default.nix`. Plugins auto-install on first launch.

```bash
# Rebuild to apply changes
hms
```

## 🔍 Finding Plugins

Browse installed plugins: `:Lazy`

For plugin configurations, see `conf/lua/plugins/` directory.

---

**Tip**: Use `:checkhealth` to diagnose issues.
