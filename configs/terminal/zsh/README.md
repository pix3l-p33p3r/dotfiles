# Zsh Configuration

A modern, feature-rich zsh configuration built with [Zap](https://github.com/zap-zsh/zap) plugin manager, optimized for development workflows and terminal productivity.

## 🚀 Features

### Core Setup
- **Plugin Manager**: Zap (fast, modern alternative to oh-my-zsh)
- **Shell Mode**: Vi mode with enhanced keybindings
- **Prompt**: agkozak-zsh-prompt with git integration
- **History**: Enhanced history with substring search
- **Completions**: Advanced completion system with fuzzy matching

### Productivity Tools
- **File Manager**: Yazi integration with `f` keybinding
- **Directory Navigation**: Smart cd with zoxide
- **History Search**: Atuin for intelligent history search
- **Autosuggestions**: Context-aware command suggestions
- **System Clipboard**: Seamless clipboard integration

### Development Tools
- **Git Tools**: lazygit, tig, git-interactive-rebase-tool
- **Docker**: lazydocker for container management
- **Database**: lazysql for database operations
- **SSH**: lazyssh for connection management
- **Cloud**: lazyhetzner for Hetzner Cloud management
- **Journal**: lazyjournal for system logs

## 📁 Structure

```
zsh/
├── README.md                 # This file
├── default.nix              # Nix configuration with packages
└── config/
    ├── .zshrc               # Main zsh configuration
    ├── .zshenv              # Environment variables
    ├── completions/         # Custom completions
    │   ├── _ovquik
    │   ├── _volta
    └── conf.d/              # Configuration modules
        ├── 100-zsh.zsh      # Core zsh options
        ├── 102-aliases.zsh  # Command aliases
        ├── 103-bindings.zsh # Key bindings
        ├── 104-functions.zsh # Custom functions
        ├── 200-completion.zsh # Completion settings
        ├── 300-plugins_config.zsh # Plugin configurations
        └── 900-startup.zsh  # Startup commands
```

## 🔧 Configuration Files

### Core Files

#### `.zshrc`
- Plugin management with Zap
- Plugin loading and initialization
- Completion system setup

#### `.zshenv`
- Environment variables
- PATH configuration
- Editor settings (nvim)
- Development tool paths (Go, Cargo, Deno, etc.)

### Configuration Modules (`conf.d/`)

#### `100-zsh.zsh` - Core Options
- Directory stack management
- History configuration
- Completion behavior
- Glob options

#### `102-aliases.zsh` - Command Aliases
```bash
# File operations
alias l="eza --icons"           # Modern ls with icons
alias ll="eza -lh"              # Long format
alias lsa="eza -lah"            # All files, long format
alias cat="bat --plain"          # Syntax highlighted cat
alias cd="z"                    # Smart cd with zoxide

# Development
alias vi="nvim"                 # Use nvim as vi
alias e="$EDITOR"               # Quick editor access
alias tx="tmux"                 # Terminal multiplexer

# System
alias myip="curl icanhazip.com"  # Check external IP
alias pg="ping 1.0.0.1 -c 5"   # Quick ping test
alias path='echo -e ${PATH//:/\\n}' # Show PATH

# Nix
alias build="cd $HOME/dotfiles && sudo nixos-rebuild switch --flake . && home-manager switch --flake . && clean"
alias clean="$HOME/dotfiles/scripts/nix-cleaner.sh"
```

#### `103-bindings.zsh` - Key Bindings
- **Vi Mode**: Full vi keybindings with enhancements
- **History Search**: `k`/`j` for substring search
- **Command Editing**: `e` to edit command in editor
- **Sudo Insert**: `Ctrl+x` to insert sudo
- **File Manager**: `f` to open yazi
- **System Clipboard**: `yy` to yank whole line

#### `104-functions.zsh` - Custom Functions
- **`note()`**: Quick note editing
- **`man()`**: Enhanced man pages with colors
- **`yazi_fm()`**: File manager integration
- **`fkill()`**: Fuzzy process killing
- **`fman()`**: Fuzzy man page search
- **`fopen()`**: Fuzzy file opening
- **`extract()`**: Universal archive extraction

#### `200-completion.zsh` - Completion System
- Case-insensitive completions
- Fuzzy matching for typos
- Caching for performance
- Grouped and colored output
- SSH host completion
- Process completion for kill commands

#### `300-plugins_config.zsh` - Plugin Settings
- **agkozak-zsh-prompt**: Clean, git-aware prompt with Catppuccin Mocha colors
- **history-substring-search**: Enhanced history search with Catppuccin colors
- **autosuggestions**: Smart command suggestions

#### `900-startup.zsh` - Startup Commands
- **macchina**: System information on login
- **direnv**: Environment management
- **atuin**: History search initialization
- **zoxide**: Smart cd initialization

## 🎯 Key Bindings

### Vi Mode Navigation
- `k`/`j` - History substring search up/down
- `Ctrl+p`/`Ctrl+n` - History search (insert mode)
- `e` - Edit command in editor
- `f` - Open yazi file manager
- `yy` - Yank whole line to system clipboard

### Completion
- `Tab` - Trigger completion
- `h`/`j`/`k`/`l` - Navigate completion menu
- `?`/`/` - Search in completion menu

### Utilities
- `Ctrl+x` - Insert sudo before command
- `Ctrl+Space` - Accept autosuggestion

## 🛠️ Installed Packages

### Shell & CLI Tools
- `atuin` - Shell history search
- `bat` - Cat with syntax highlighting
- `eza` - Modern ls replacement
- `fastfetch` - System information
- `fd` - Find replacement
- `fzf` - Fuzzy finder
- `ripgrep` - Fast text search
- `tmux` - Terminal multiplexer
- `tree` - Directory tree
- `yazi` - File manager
- `zoxide` - Smart cd

### Development Tools
- **Version Control**: `git`, `git-lfs`, `git-crypt`, `git-secrets`, `gh`, `glab`
- **Code Quality**: `shellcheck`, `shfmt`, `hadolint`, `yamllint`, `prettier`
- **Build Tools**: `cmake`, `ninja`, `meson`, `pkg-config`
- **Package Managers**: `pipx`, `cargo`, `go`, `nodejs`, `yarn`, `pnpm`

### TUI Applications
- **Git**: `lazygit`, `tig`, `git-interactive-rebase-tool`, `gitui`
- **DevOps**: `lazydocker`, `lazysql`, `lazyssh`, `lazyhetzner`, `lazyjournal`
- **Development**: `stern` (Kubernetes log tailing)

### Environment Management
- `direnv` - Environment management

## 🚀 Getting Started

### Prerequisites
- Nix package manager
- Home Manager
- Zap plugin manager (auto-installed)

### Installation
The configuration is managed through Nix and Home Manager. Simply rebuild your system:

```bash
# From your dotfiles directory
sudo nixos-rebuild switch --flake .
home-manager switch --flake .
```

### First Run
On first login, Zap will automatically install all plugins. The configuration will:
1. Install Zap plugin manager
2. Load all plugins
3. Initialize development tools (direnv, atuin, zoxide)
4. Display system information with macchina

## 🔧 Customization

### Adding New Aliases
Edit `config/conf.d/102-aliases.zsh`:

```bash
# Add your custom aliases
alias myalias="mycommand --option"
```

### Adding New Functions
Edit `config/conf.d/104-functions.zsh`:

```bash
function myfunction() {
    # Your function code here
}
```

### Adding New Plugins
Edit `config/.zshrc`:

```bash
# Add new plugins
plug "username/plugin-name"
```

### Custom Completions
The `config/completions/` directory contains custom zsh completion scripts for various tools and applications. These files provide intelligent command-line completion and follow zsh completion naming conventions (starting with `_`).

#### Available Completion Files:

**`_ovquik`** (317B, 13 lines)
- **Purpose**: Completion for `ovquik` OpenVPN management tool
- **Features**: 
  - Server connection/disconnection completion
  - Dynamic server list from `.ovpn` files
  - Status and disconnect options
- **Usage**: Provides tab completion for VPN server names and commands

**`_volta`** (9.4KB, 300 lines)
- **Purpose**: Completion for Volta JavaScript toolchain manager
- **Features**:
  - Node.js version management completion
  - Package installation and removal
  - Project and global tool management
  - Verbose/quiet mode options
- **Usage**: Intelligent completion for all Volta commands and options

#### Adding New Completions
To add custom completion files:
1. Create a file starting with `_` in `config/completions/`
2. Follow zsh completion script conventions
3. Use `#compdef <command>` to specify the command
4. Implement completion logic using zsh completion functions
5. The completions will be automatically loaded by the zsh configuration

## 🎨 Prompt Customization

The prompt uses agkozak-zsh-prompt with **Catppuccin Mocha** colors. Customize it in `config/conf.d/300-plugins_config.zsh`:

### Catppuccin Mocha Color Scheme
```bash
# Catppuccin Mocha Colors for agkozak prompt
AGKOZAK_COLORS_EXIT_STATUS=red          # #f38ba8 (red)
AGKOZAK_COLORS_USER_HOST=blue           # #89b4fa (blue)
AGKOZAK_COLORS_PATH=green               # #a6e3a1 (green)
AGKOZAK_COLORS_BRANCH_STATUS=yellow     # #f9e2af (yellow)
AGKOZAK_COLORS_PROMPT_CHAR=white        # #bac2de (white/foreground)
AGKOZAK_COLORS_CMD_EXEC_TIME=cyan       # #94e2d5 (teal)
AGKOZAK_COLORS_VIRTUALENV=magenta       # #cba6f7 (mauve)
AGKOZAK_COLORS_BG_STRING=magenta        # #cba6f7 (mauve)

# Modern prompt characters
AGKOZAK_PROMPT_CHAR='❯'               # Success prompt
AGKOZAK_PROMPT_CHAR_FAIL='✗'          # Error prompt
```

### Customization Options
```bash
# Change colors to other Catppuccin variants
AGKOZAK_COLORS_USER_HOST=cyan          # For macchiato variant
AGKOZAK_COLORS_PATH=blue              # For frappe variant
```

## 🔍 Troubleshooting

### Performance Issues
- Check startup time: `timezsh`
- Profile zsh: `ZSH_DEBUGRC=1 zsh -i -c exit`

### Plugin Issues
- Reinstall Zap: Remove `~/.local/share/zap` and restart shell
- Check plugin compatibility

### Completion Issues
- Clear completion cache: `rm -rf ~/.cache/zsh/zcompcache`
- Regenerate completions: `autoload -U compinit && compinit`

## 📚 Resources

- [Zap Documentation](https://github.com/zap-zsh/zap)
- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [agkozak-zsh-prompt](https://github.com/agkozak/agkozak-zsh-prompt)
- [Atuin](https://github.com/atuinsh/atuin)
- [Zoxide](https://github.com/ajeetdsouza/zoxide)
- [Yazi](https://github.com/sxyazi/yazi)



*This configuration is optimized for development workflows and terminal productivity. Feel free to customize it to match your specific needs.*
