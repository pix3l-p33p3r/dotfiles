# Neovim Configuration

Modern Neovim setup with Lazy.nvim plugin manager, LSP, and GitHub Copilot.

## Features

**Core**
- Plugin Manager: Lazy.nvim
- Colorscheme: Catppuccin Mocha
- LSP: Native with comprehensive language support
- Completion: Native with LSP integration
- Treesitter: Advanced syntax highlighting
- AI: GitHub Copilot

**Development**
- LSP Servers: TypeScript, Python, Rust, Go, C/C++, Lua, Nix, Bash
- Formatters: Prettier, Black, Stylua, Rustfmt, Nixfmt
- Linters: ESLint, Pylint, Typos-lsp
- Git: GitSigns integration

## Structure

```
nvim/
├── default.nix          # Nix configuration
└── conf/
    ├── init.lua         # Entry point
    ├── lua/config/      # Core config
    └── lua/plugins/     # Plugin configs
```

## Essential Keybindings

**Leader: `<Space>`**

| Action | Keybind |
|--------|---------|
| File explorer | `<leader>e` |
| Save | `<C-s>` |
| Find files | `<leader>sf` |
| Live grep | `<leader>sg` |
| LSP hover | `<leader>lk` |
| LSP rename | `<leader>lr` |
| Code actions | `<leader>la` |
| Copilot accept | `<C-Space>` |
| Copilot panel | `<C-S-p>` |

## GitHub Copilot Setup

```bash
# Authenticate
gh auth login

# Start Neovim - Copilot installs automatically
nvim
```

## Customization

- Add plugins: Create file in `lua/plugins/`
- Modify keybindings: Edit `plugin/keymaps/`
- LSP config: Edit `lua/config/lsp.lua`
