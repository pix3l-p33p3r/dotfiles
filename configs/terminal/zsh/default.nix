{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # ============================================================================
    # |                         SHELL & CLI TOOLS                                |
    # ============================================================================
    # Shell Enhancement
    atuin # Shell history search
    zoxide # Smart cd

    # File Operations
    bat # Cat with syntax highlighting
    eza # Modern ls replacement
    fd # Find replacement
    fzf # Fuzzy finder
    tree # Directory tree
    trashy # Trash utility
    yazi # File manager

    # System Information
    fastfetch # System information
    macchina # System information
    nix-tree # Nix dependency tree

    # Text Processing
    glow # Markdown viewer
    ripgrep # Fast text search
    tldr # Simplified man pages

    # Network Tools
    gping # Ping with graph

    # Terminal Utilities
    bb # Command line tool
    tmux # Terminal multiplexer
    tt # Terminal typing test
    ueberzugpp # Image preview

    # ============================================================================
    # |                        DEVELOPMENT UTILITIES                             |
    # ============================================================================
    # Version Control
    git # Version control system
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
    cmake # Cross-platform build system
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

    # ============================================================================
    # |                            TUI APPLICATIONS                              |
    # ============================================================================
    # Git TUI Tools
    tig # Git repository browser
    git-interactive-rebase-tool # Interactive rebase
    gitui # Git TUI
    lazygit # Git TUI

    # Development TUI
    lazydocker # Docker TUI
    lazysql # SQL database TUI
    lazyjournal # Journal TUI
    lazyhetzner # Hetzner Cloud TUI
    stern # Kubernetes log tailing

    # ============================================================================
    # |                        ENVIRONMENT MANAGEMENT                             |
    # ============================================================================
    direnv # Environment management
  ];

  programs.zsh.enable = true;

  home.sessionVariables = {
    ZDOTDIR = "$HOME/.config/zsh";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Add local bin to PATH
  home.sessionPath = [ "$HOME/.local/bin" ];

  home.file = {
    ".config/zsh" = {
      source = ./config;
      recursive = true;
    };
  };
}