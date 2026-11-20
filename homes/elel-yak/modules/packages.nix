{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Shell / navigation
    atuin
    carapace
    nushell
    zoxide
    direnv
    starship

    # Files
    bat
    eza
    fd
    fzf
    tree
    trashy
    yazi
    dust
    duf
    procs
    jq
    yq-go
    fq

    # Sysinfo / TUI
    btop
    bottom
    macchina
    fastfetch
    nix-tree

    # Text
    glow
    ripgrep
    tldr
    neovim
    helix
    delta

    # Net
    gping
    curl
    wget

    # Terminal
    tmux
    ueberzugpp

    # VCS + lazy TUIs
    git
    git-lfs
    git-crypt
    git-secrets
    gh
    glab
    gitui
    tig
    git-interactive-rebase-tool
    lazygit
    lazydocker
    lazyjournal
    lazysql
    jujutsu

    # Lint / fmt
    shellcheck
    shfmt
    hadolint
    yamllint
    prettier

    # Build / langs
    cmake
    ninja
    meson
    pkg-config
    nodejs
    yarn
    pnpm
    python3
    (pipx.overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    }))
    go

    # nvim LSP / fmt essentials
    nixd
    pyright
    rust-analyzer
    gopls
    clang-tools
    bash-language-server
    typescript-language-server
    lua-language-server
    yaml-language-server
    nixfmt
    stylua
    black

    # Browser (dock)
    google-chrome

    # Nix tooling (needed for HM activation / nix-env)
    nix
  ];
}
