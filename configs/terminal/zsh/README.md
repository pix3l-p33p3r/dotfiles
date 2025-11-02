# Zsh Configuration

Modern zsh setup with Zap plugin manager and Vi mode.

## Features

- Plugin Manager: Zap
- Shell Mode: Vi with enhanced keybindings
- Prompt: agkozak-zsh-prompt (Catppuccin Mocha)
- History: Substring search + Atuin
- Completions: Advanced fuzzy completion
- Tools: Yazi, zoxide, autosuggestions

## Structure

```
zsh/
├── default.nix          # Nix configuration
└── config/
    ├── .zshrc           # Main config
    ├── completions/     # Custom completions
    └── conf.d/          # Config modules
```

## Essential Keybindings

| Action | Keybind |
|--------|---------|
| History search | `k`/`j` |
| File manager | `f` |
| Insert sudo | `Ctrl+x` |
| Accept suggestion | `Ctrl+Space` |

## Key Aliases

```bash
l="eza --icons"          # Modern ls
ll="eza -lh"             # Long format
cat="bat --plain"        # Syntax cat
cd="z"                   # Smart cd
vi="nvim"                # Neovim
```

## Useful Functions

- `note()` - Quick note editing
- `fkill()` - Fuzzy process killing
- `extract()` - Universal archive extraction

## Packages

CLI: atuin, bat, eza, fd, fzf, ripgrep, tmux, yazi, zoxide  
Git: lazygit, tig, gitui  
DevOps: lazydocker, lazysql
