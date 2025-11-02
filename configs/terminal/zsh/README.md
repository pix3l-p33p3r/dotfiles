<div align="center">
    <img alt="zsh" src="https://img.shields.io/badge/Shell-Zsh-blue.svg?style=for-the-badge&labelColor=11111B&logo=gnu-bash&logoColor=89B4FA&color=89B4FA">
    <img alt="zap" src="https://img.shields.io/badge/Plugin%20Manager-Zap-purple.svg?style=for-the-badge&labelColor=11111B&logo=alacritty&logoColor=89B4FA&color=89B4FA">
    <img alt="vi" src="https://img.shields.io/badge/Mode-Vi-green.svg?style=for-the-badge&labelColor=11111B&logo=vim&logoColor=89B4FA&color=89B4FA">
</div>

<br>

# Zsh Configuration

Modern zsh setup with [Zap](https://github.com/zap-zsh/zap) plugin manager, optimized for productivity and development.

## ✨ Features

- **Plugin Manager**: Zap (fast and modern)
- **Shell Mode**: Vi mode with enhanced keybindings
- **Prompt**: agkozak-zsh-prompt with Catppuccin Mocha colors
- **History**: Enhanced with substring search and Atuin
- **Completions**: Advanced fuzzy completion system
- **Productivity**: Yazi, zoxide, autosuggestions, clipboard integration

## 📁 Structure

```
zsh/
├── default.nix              # Nix configuration
└── config/
    ├── .zshrc               # Main zsh config
    ├── .zshenv              # Environment variables
    ├── completions/         # Custom completions
    │   ├── _ovquik
    │   └── _volta
    └── conf.d/              # Configuration modules
        ├── 100-zsh.zsh      # Core options
        ├── 102-aliases.zsh  # Aliases
        ├── 103-bindings.zsh # Keybindings
        ├── 104-functions.zsh # Functions
        ├── 200-completion.zsh # Completion
        ├── 300-plugins_config.zsh # Plugins
        └── 900-startup.zsh  # Startup
```

## ⌨️ Keybindings

| Action | Keybind |
|--------|---------|
| History search | `k`/`j` |
| Edit command | `e` |
| File manager | `f` |
| Yank line | `yy` |
| Insert sudo | `Ctrl+x` |
| Accept suggestion | `Ctrl+Space` |

## 🔖 Aliases

```bash
l="eza --icons"              # Modern ls
ll="eza -lh"                 # Long format
cat="bat --plain"            # Syntax highlighted cat
cd="z"                       # Smart cd with zoxide
vi="nvim"                    # Use nvim as vi
e="$EDITOR"                  # Quick editor access
tx="tmux"                    # Terminal multiplexer
```

## ⚙️ Functions

- **`note()`**: Quick note editing
- **`man()`**: Enhanced colored man pages
- **`fkill()`**: Fuzzy process killing
- **`fman()`**: Fuzzy man page search
- **`fopen()`**: Fuzzy file opening
- **`extract()`**: Universal archive extraction

## 📦 Packages

**CLI Tools**: atuin, bat, eza, fd, fzf, ripgrep, tmux, tree, yazi, zoxide  
**Git Tools**: lazygit, tig, gitui, git-interactive-rebase-tool  
**DevOps**: lazydocker, lazysql, lazyssh, lazyhetzner, lazyjournal  
**Build Tools**: git, gh, cmake, ninja, cargo, go, nodejs  

## 🎨 Customization

Edit the files in `config/conf.d/` to customize:
- Add aliases: `102-aliases.zsh`
- Add functions: `104-functions.zsh`
- Add plugins: `.zshrc`
- Add completions: `completions/`

## 📚 Resources

- [Zap Documentation](https://github.com/zap-zsh/zap)
- [agkozak-zsh-prompt](https://github.com/agkozak/agkozak-zsh-prompt)
- [Atuin](https://github.com/atuinsh/atuin)
- [Zoxide](https://github.com/ajeetdsouza/zoxide)
- [Yazi](https://github.com/sxyazi/yazi)