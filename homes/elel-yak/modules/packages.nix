{ lib, pkgs, pkgs2405, ... }:
let
  # Newer than the pinned nixpkgs. To bump: change version, run
  # `nix store prefetch-file <url>`, paste the hash.
  grok = pkgs.grok-build.overrideAttrs (old: rec {
    version = "1.0.92";
    src = pkgs.fetchurl {
      url = "https://x.ai/cli/grok-${version}-linux-x86_64";
      hash = "sha256-rdTSAdvywL1gd6Nv61WnaTneMLrkjbsG8WsjB9OM6ss=";
    };
  });
  cursorCli = pkgs.cursor-cli.overrideAttrs (old: rec {
    version = "2026.11.22-e9042b2";
    src = pkgs.fetchurl {
      url = "https://downloads.cursor.com/lab/${version}/linux/x64/agent-cli-package.tar.gz";
      hash = "sha256-dmOxxdG1bgle+OI77zjWbfbP1mXEhzRwIU4OQR8Pl7M=";
    };
    postInstall = (old.postInstall or "") + ''
      ln -s cursor-agent $out/bin/agent
    '';
  });
in
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
    grok # xAI Grok terminal agent (`grok`)
    # grok-build also ships `agent`; that name belongs to Cursor's CLI.
    (lib.hiPrio cursorCli) # Cursor CLI (`agent`, `cursor-agent`)
  ];
}
