# Neovim Configuration

A modern, feature-rich Neovim configuration built with [Lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager, optimized for development workflows and maximum productivity.

## 🚀 Features

### Core Setup
- **Plugin Manager**: Lazy.nvim (fast, modern plugin manager)
- **Colorscheme**: Catppuccin (Mocha variant)
- **LSP**: Native LSP with comprehensive language support
- **Completion**: Native completion with LSP integration
- **Treesitter**: Advanced syntax highlighting and parsing
- **AI Assistant**: GitHub Copilot for intelligent code completion

### Development Tools
- **LSP Servers**: TypeScript, Python, Rust, Go, C/C++, Lua, Nix, and more
- **Formatters**: Prettier, Black, Stylua, Rustfmt, Nixfmt
- **Linters**: ESLint, Pylint, Typos-lsp
- **Git Integration**: GitSigns, Git commands via Telescope
- **File Management**: Neo-tree, Oil.nvim

### Productivity Features
- **Fuzzy Finding**: Telescope for files, buffers, grep, and more
- **Navigation**: Leap for quick movement, enhanced window navigation
- **Code Actions**: LSP Saga for enhanced LSP features
- **Auto-completion**: Native completion with LSP
- **AI Code Completion**: GitHub Copilot with intelligent suggestions
- **Auto-pairs**: Smart bracket and quote pairing
- **Auto-save**: Automatic file saving
- **Session Management**: Persistence for session restoration

## 📁 Structure

```
nvim/
├── README.md                 # This file
├── default.nix              # Nix configuration with packages and LSP servers
└── conf/
    ├── init.lua             # Main configuration entry point
    ├── lazy-lock.json       # Plugin lock file
    ├── after/               # After plugins load
    │   └── ftplugin/        # Filetype-specific settings
    │       ├── help.lua     # Help file settings
    │       └── lua.lua      # Lua file settings
    ├── lua/
    │   ├── config/          # Core configuration
    │   │   ├── lazy.lua     # Lazy.nvim setup
    │   │   ├── lsp.lua      # LSP configuration
    │   │   ├── neovide.lua  # Neovide GUI settings
    │   │   └── options.lua  # Neovim options
    │   └── plugins/         # Plugin configurations
    │       ├── alpha.lua     # Startup screen
    │       ├── auto-pairs.lua # Auto-pairing
    │       ├── auto-save.lua # Auto-save
    │       ├── blink.lua     # Completion engine
    │       ├── bufferline.lua # Buffer line
    │       ├── comment.lua   # Commenting
    │       ├── conform.lua   # Formatting
    │       ├── copilot.lua   # GitHub Copilot AI assistant
    │       ├── eye-linter.lua # Linting
    │       ├── gitsigns.lua  # Git signs
    │       ├── hover.lua     # Hover documentation
    │       ├── ident.lua     # Indentation
    │       ├── inlay-hints.lua # Inlay hints
    │       ├── leap.lua      # Quick navigation
    │       ├── lspsaga.lua   # LSP Saga
    │       ├── lualine.lua   # Status line
    │       ├── markdown.lua  # Markdown support
    │       ├── mini.lua      # Mini plugins
    │       ├── misc.lua      # Miscellaneous plugins
    │       ├── modes.lua     # Mode indicators
    │       ├── neo-tree.lua  # File explorer
    │       ├── neoscroll.lua # Smooth scrolling
    │       ├── catppuccin.lua # Colorscheme
    │       ├── nvim-tree.lua # Alternative file explorer
    │       ├── oil.lua       # File editing
    │       ├── project.lua   # Project management
    │       ├── surround.lua  # Surround operations
    │       ├── syntax-highlighting.lua # Enhanced syntax
    │       ├── telescope.lua # Fuzzy finder
    │       ├── timber.lua    # Logging
    │       ├── tiny-inline-diagnostic.lua # Inline diagnostics
    │       ├── toggleterm.lua # Terminal
    │       ├── treesj.lua    # Tree-sitter based splitting
    │       ├── visual-whitespace.lua # Whitespace visualization
    │       ├── which-key.lua # Key binding help
    │       └── windows.lua   # Window management
    └── plugin/              # Plugin-specific configurations
        └── keymaps/         # Key mappings
            ├── insert.lua    # Insert mode mappings
            └── normal.lua    # Normal mode mappings
```

## 🔧 Configuration Files

### Core Files

#### `init.lua`
- Main entry point
- Loads core configuration modules
- Handles Neovide GUI setup

#### `lua/config/options.lua`
- Neovim options and settings
- Leader key configuration (`<Space>`)
- Editor behavior settings
- UI customization

#### `lua/config/lazy.lua`
- Lazy.nvim plugin manager setup
- Plugin loading configuration
- Update and change detection settings

#### `lua/config/lsp.lua`
- Language Server Protocol configuration
- LSP server settings for multiple languages
- Custom LSP configurations

### Plugin Configurations (`lua/plugins/`)

#### Core Plugins
- **catppuccin.nvim**: Colorscheme (Mocha variant)
- **lazy.nvim**: Plugin manager
- **telescope.nvim**: Fuzzy finder
- **lspsaga.nvim**: Enhanced LSP features
- **neo-tree.nvim**: File explorer
- **bufferline.nvim**: Buffer management

#### Development Plugins
- **nvim-treesitter**: Syntax highlighting
- **blink.nvim**: Completion engine
- **conform.nvim**: Code formatting
- **eye-linter.nvim**: Linting
- **gitsigns.nvim**: Git integration
- **hover.nvim**: Documentation hover
- **copilot.vim**: GitHub Copilot AI assistant

#### Productivity Plugins
- **leap.nvim**: Quick navigation
- **surround.nvim**: Surround operations
- **comment.nvim**: Commenting
- **auto-pairs.nvim**: Auto-pairing
- **auto-save.nvim**: Auto-save
- **which-key.nvim**: Key binding help

## 🎯 Key Bindings

### Leader Key: `<Space>`

#### File Operations
- `<leader>e` - Toggle Neo-tree file explorer
- `<leader>c` - Close current buffer
- `<leader>qq` - Force quit all
- `<C-s>` - Save file

#### Navigation
- `<C-h/j/k/l>` - Move between splits
- `<S-h/l>` - Navigate buffers
- `<leader>h` - Clear search highlights
- `<Esc>` - Clear search highlights

#### Search & Find
- `<leader>sf` - Find files (Telescope)
- `<leader>sb` - Find buffers (Telescope)
- `<leader>sg` - Live grep (Telescope)
- `<leader>sr` - Search registers (Telescope)
- `<leader>s/` - Leap forward
- `<leader>s?` - Leap backward

#### LSP Operations
- `<leader>lk` - Hover documentation
- `<leader>lr` - Rename symbol
- `<leader>la` - Code actions
- `<leader>ld` - Go to definition
- `<leader>lR` - Find references
- `<leader>lS` - Workspace symbols
- `<leader>lD` - Show diagnostics
- `<leader>ln` - Next diagnostic
- `<leader>lp` - Previous diagnostic
- `<leader>le` - Show line diagnostics
- `<leader>lo` - LSP outline

#### Git Operations
- `<leader>gc` - Git commits (Telescope)
- `<leader>gb` - Git branches (Telescope)
- `<leader>gs` - Git status (Telescope)

#### GitHub Copilot
- `Ctrl+Space` - Accept Copilot suggestion
- `Ctrl+Right` - Accept word suggestion
- `Ctrl+Escape` - Dismiss suggestion
- `Ctrl+]` - Next suggestion
- `Ctrl+[` - Previous suggestion
- `Ctrl+Shift+P` - Open Copilot panel
- `Ctrl+Shift+S` - Show Copilot status
- `Ctrl+Shift+E` - Enable Copilot
- `Ctrl+Shift+D` - Disable Copilot
- `<leader>cp` - Open Copilot panel (normal mode)
- `<leader>cs` - Show Copilot status (normal mode)
- `<leader>ce` - Enable Copilot (normal mode)
- `<leader>cd` - Disable Copilot (normal mode)

#### Session Management
- `<leader>pr` - Restore session
- `<leader>pl` - Restore last session

#### Window Management
- `<M-h/l>` - Resize split width
- `<M-j/k>` - Resize split height
- `<M-=>` - Equalize split sizes

### Arrow Key Reminders
- `<left>` - "Use h to move!!"
- `<right>` - "Use l to move!!"
- `<up>` - "Use k to move!!"
- `<down>` - "Use j to move!!"

## 🛠️ Installed Packages

### Core Dependencies
- **neovide** - GUI frontend for Neovim
- **nodejs** - JavaScript runtime
- **gcc** - C/C++ compiler
- **git** - Version control
- **cargo** - Rust package manager
- **gnumake** - Build system
- **tree-sitter** - Parser generator
- **ripgrep** - Fast text search
- **inotify-tools** - File system monitoring

### Language Servers
- **nixd** - Nix language server
- **pyright** - Python language server
- **eslint_d** - JavaScript/TypeScript linter
- **pylint** - Python linter
- **rust-analyzer** - Rust language server
- **gopls** - Go language server
- **clang-tools** - C/C++ language server
- **typos-lsp** - Typo detection
- **bash-language-server** - Bash language server
- **svelte-language-server** - Svelte language server
- **typescript-language-server** - TypeScript language server
- **vscode-langservers-extracted** - HTML/CSS/JSON language servers
- **emmet-ls** - Emmet language server
- **harper** - Spell checker
- **lua-language-server** - Lua language server
- **tailwindcss-language-server** - Tailwind CSS language server
- **yaml-language-server** - YAML language server

### Formatters
- **nixfmt** - Nix formatter
- **prettier** - JavaScript/TypeScript formatter
- **prettierd** - Prettier daemon
- **black** - Python formatter
- **stylua** - Lua formatter
- **rustfmt** - Rust formatter

### Tree-sitter Parsers
- **asm, bash, c, cpp, css, csv, diff, dockerfile**
- **gitattributes, gitcommit, git_config, gitignore**
- **go, goctl, gomod, gosum, html, ini, javascript**
- **jsdoc, json, just, latex, linkerscript, lua**
- **make, markdown, nasm, nginx, objdump, passwd**
- **proto, python, regex, rust, scss, ssh_config**
- **strace, toml, tsx, typescript, udev, vim**
- **vimdoc, vue, xml, yaml**

## 🚀 Getting Started

### Prerequisites
- Nix package manager
- Home Manager
- Neovim 0.9+

### Installation
The configuration is managed through Nix and Home Manager. Simply rebuild your system:

```bash
# From your dotfiles directory
sudo nixos-rebuild switch --flake .
home-manager switch --flake .
```

### First Run
On first launch, Lazy.nvim will automatically:
1. Install all plugins
2. Set up LSP servers
3. Configure Tree-sitter parsers
4. Initialize all plugin configurations

### GitHub Copilot Setup
GitHub Copilot requires authentication:
1. **Authenticate with GitHub CLI:**
   ```bash
   gh auth login
   ```
2. **Start Neovim** - Copilot will automatically install via lazy.nvim
3. **Test Copilot** - Start typing code to see AI suggestions

### GUI Usage (Neovide)
If you prefer a GUI, Neovide is included and configured:
```bash
neovide
```

## 🔧 Customization

### Adding New Plugins
Edit `lua/plugins/` directory and create a new `.lua` file:

```lua
-- lua/plugins/my-plugin.lua
return {
  "username/plugin-name",
  config = function()
    -- Plugin configuration
  end,
}
```

### Modifying Key Bindings
Edit `plugin/keymaps/normal.lua` or `plugin/keymaps/insert.lua`:

```lua
-- Add new key binding
vim.keymap.set("n", "<leader>mykey", "<cmd>MyCommand<cr>", { desc = "My command" })
```

### LSP Server Configuration
Edit `lua/config/lsp.lua` to add new language servers:

```lua
vim.lsp.config.my_ls = {
  cmd = { "my-language-server" },
  filetypes = { "myfiletype" },
  root_markers = { ".git" },
}
```

### Colorscheme Customization
Edit `lua/plugins/catppuccin.lua`:

```lua
-- Change colorscheme
vim.cmd([[colorscheme catppuccin-macchiato]]) -- or other catppuccin variants
```

## 🎨 Themes

The configuration uses **Catppuccin** colorscheme with the **Mocha** variant. Available variants:
- `mocha` (default) - Dark theme with warm tones
- `macchiato` - Dark theme with cooler tones
- `frappe` - Dark theme with balanced tones
- `latte` - Light theme

## 🔍 Troubleshooting

### Plugin Issues
- Check Lazy.nvim status: `:Lazy`
- Update plugins: `:Lazy update`
- Clean plugins: `:Lazy clean`

### LSP Issues
- Check LSP status: `:LspInfo`
- Restart LSP: `:LspRestart`
- Check LSP logs: `:LspLog`

### Performance Issues
- Check startup time: `:Lazy profile`
- Profile plugins: `:Lazy profile`
- Check for slow plugins

### Tree-sitter Issues
- Update parsers: `:TSUpdate`
- Check parser status: `:TSInstallInfo`
- Reinstall parsers: `:TSInstall <parser>`

## 📚 Resources

- [Neovim Documentation](https://neovim.io/doc/)
- [Lazy.nvim](https://github.com/folke/lazy.nvim)
- [LSP Configuration](https://neovim.io/doc/user/lsp.html)
- [Tree-sitter](https://tree-sitter.github.io/tree-sitter/)
- [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [LSP Saga](https://github.com/glepnir/lspsaga.nvim)
- [Catppuccin](https://github.com/catppuccin/nvim)
- [GitHub Copilot](https://github.com/github/copilot.vim)

## 🤝 Contributing

To improve this configuration:
1. Test changes in a separate branch
2. Document new features
3. Update this README
4. Submit a pull request

---

*This configuration is optimized for development workflows and maximum productivity. Feel free to customize it to match your specific needs.*

## 📝 Last Updated

- Date: 2025-10-31
- Changes:
  - Repository docs refreshed; see root README for system changes
