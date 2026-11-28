{ lib, pkgs, pkgs2405, ... }:
{
  home.packages = with pkgs; [
    # ── Shell / navigation ─────────────────────────────────────────────
    atuin
    carapace
    nushell
    zoxide
    direnv
    starship # optional; agkozak stays default via zap

    # ── Files ──────────────────────────────────────────────────────────
    bat
    eza
    fd
    fzf
    tree
    trashy
    # yazi: programs.yazi in configs/terminal/yazi.nix
    sl
    dust
    duf
    procs
    jq
    yq-go
    fq

    # ── Sysinfo / TUI ──────────────────────────────────────────────────
    btop
    bottom
    macchina
    fastfetch
    nix-tree

    # ── Text ───────────────────────────────────────────────────────────
    glow
    ripgrep
    tldr
    neovim
    helix
    delta

    # ── Net ────────────────────────────────────────────────────────────
    gping
    curl
    wget

    # ── Terminal ───────────────────────────────────────────────────────
    tmux
    ueberzugpp

    # ── VCS + lazy TUIs ────────────────────────────────────────────────
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

    # ── Lint / fmt ─────────────────────────────────────────────────────
    shellcheck
    shfmt
    hadolint
    yamllint
    prettier

    # ── Build / langs ──────────────────────────────────────────────────
    cmake
    ninja
    meson
    pkg-config
    # Node binary only. npm, npx, yarn, and pnpm stay out of the global
    # profile — a JS repo gets them from its own devenv, then toolchain-gc.
    nodejs-slim
    (python3.withPackages (ps: [
      ps.openai
      ps.textual # 42_Holes TUI; profile python has no pip
    ]))
    (pipx.overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    }))
    go

    # ── nvim LSP / fmt essentials ──────────────────────────────────────
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

    # ── Fonts (Electron FHS blanks text without these — /usr is shadowed) ─
    cantarell-fonts
    dejavu_fonts
    noto-fonts
    gsettings-desktop-schemas

    # ── Media (ImageMagick `animate` shells out to this) ──────────────
    ffmpeg

    # ── Browser (dock) ─────────────────────────────────────────────────
    google-chrome

    # ── GUI apps (Nix-managed; launchers nix-enter + nixGLIntel) ──────
    kitty
    (code-cursor.override { commandLineArgs = "--no-sandbox"; })

    # ── OpenCL (RT dual-GPU: AMD rusticl + Intel NEO) ──────────────────
    clinfo
    ocl-icd
    opencl-headers
    intel-compute-runtime # Intel UHD 770 (ADL-S) OpenCL NEO

    # ── Nix tooling (needed for HM activation / nix-env) ────────────
    nix
    # Per-project shells: rustc/cargo & elan come from devenv, not goinfre.
    devenv
    # Thin elan launcher only — toolchains live under $ELAN_HOME on hynix.
    elan
  ] ++ [
    # Mesa 24.05 rusticl — exposes RX 6500 on kernel 5.15 (unstable mesa needs 6.11+)
    pkgs2405.mesa.opencl
    (pkgs.callPackage ../../../configs/editors/grok-bot.nix { })
  ] ++ lib.optionals (pkgs ? grok-build) [
    pkgs.grok-build # xAI Grok terminal agent (`grok`) when present in pinned nixpkgs
  ];
}
