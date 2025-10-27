{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # --------------------------------------------------------------------------
    # |                         Shell & CLI Tools                              |
    # --------------------------------------------------------------------------
    atuin # Shell history search
    bat # Cat with syntax highlighting
    bb # Command line tool
    eza # Modern ls replacement
    fastfetch # System information
    fd # Find replacement
    fzf # Fuzzy finder
    gping # Ping with graph
    macchina # System information
    nix-tree # Nix dependency tree
    ripgrep # Fast text search
    tldr # Simplified man pages
    tmux # Terminal multiplexer
    trashy # Trash utility
    tree # Directory tree
    tt # Terminal typing test
    ueberzugpp # Image preview
    yazi # File manager
    zoxide # Smart cd

    # --------------------------------------------------------------------------
    # |                        Development Utilities                           |
    # --------------------------------------------------------------------------
    # Version Control
    git # Version control
    git-lfs # Git large file storage
    git-crypt # Git encryption
    git-secrets # Git secrets scanner
    gh # GitHub CLI
    glab # GitLab CLI
    
    # Code Quality & Linting
    shellcheck # Shell script linter
    shfmt # Shell formatter
    hadolint # Dockerfile linter
    yamllint # YAML linter
    prettier # Code formatter
    
    # Build Tools
    cmake # Build system
    ninja # Build system
    meson # Build system
    pkg-config # Package configuration
    
    # Package Managers
    pipx # Python package installer
    cargo # Rust package manager
    go # Go compiler
    nodejs # JavaScript runtime
    yarn # Node package manager
    pnpm # Node package manager

    # --------------------------------------------------------------------------
    # |                            TUI Applications                            |
    # --------------------------------------------------------------------------
    # Git TUI Tools
    tig # Git repository browser
    git-interactive-rebase-tool # Interactive rebase
    gitui # Git TUI
    
    # Development TUI
    stern # Kubernetes log tailing
    
    # Lazy Tools
    lazyssh # SSH connection manager
    lazygit # Git TUI
    lazydocker # Docker TUI
    lazysql # SQL database TUI
    lazyjournal # Journal TUI
    lazyhetzner # Hetzner Cloud TUI


    # --------------------------------------------------------------------------
    # |                        Environment Management                          |
    # --------------------------------------------------------------------------
    direnv # Environment management
  ];

  programs.zsh.enable = true;

  home.sessionVariables = {
    ZDOTDIR = "$HOME/.config/zsh";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.file = {
    ".config/zsh" = {
      source = ./config;
      recursive = true;
    };
  };
}
