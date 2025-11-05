{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # ============================================================================
    # |                            DEVELOPMENT TOOLS                            |
    # ============================================================================
    # Version Control
    git # Version control system
    git-lfs # Git large file storage
    git-crypt # Git encryption
    git-secrets # Git secrets scanner
    gh # GitHub CLI
    glab # GitLab CLI

    # Build Systems
    cmake # Cross-platform build system
    ninja # Build system
    meson # Build system
    pkg-config # Package configuration
    gnumake # Build automation tool

    # Compilers & Toolchains
    gcc # C/C++ compiler
    clang # LLVM/Clang compiler
    llvm # LLVM toolchain
    lld # LLVM linker
    binutils # GNU binutils (ld, objdump, etc.)
    gdb # GNU debugger
    nasm # Netwide assembler (x86)
    yasm # Yet another assembler (x86)
    riscv64-embedded-gcc # RISC-V cross toolchain

    # Languages
    rustc # Rust compiler
    zig # Zig compiler
    ghc # Haskell compiler
    nim # Nim compiler
    go # Go compiler
    python3 # Python interpreter
    lua # Lua interpreter

    # Package Managers
    cargo # Rust package manager
    go # Go compiler
    nodejs # JavaScript runtime
    yarn # Node package manager
    pnpm # Node package manager
    pipx # Python package installer

    # Code Quality & Linting
    shellcheck # Shell script linter
    shfmt # Shell formatter
    hadolint # Dockerfile linter
    yamllint # YAML linter
    prettier # Code formatter
    prettierd # Prettier daemon
    black # Python formatter
    stylua # Lua formatter
    rustfmt # Rust formatter
    nixfmt # Nix formatter

    # Language Servers
    nixd # Nix language server
    pyright # Python language server
    eslint_d # JavaScript/TypeScript linter daemon
    pylint # Python linter
    rust-analyzer # Rust language server
    gopls # Go language server
    clang-tools # C/C++ language server
    typos-lsp # Typo checker language server
    bash-language-server # Bash language server
    svelte-language-server # Svelte language server
    typescript-language-server # TypeScript language server
    vscode-langservers-extracted # VS Code language servers
    emmet-ls # Emmet language server
    harper # Harper language server
    lua-language-server # Lua language server
    tailwindcss-language-server # Tailwind CSS language server
    yaml-language-server # YAML language server

    # Development Utilities
    ripgrep # Fast text search
    fd # Find replacement
    tree-sitter # Parser generator
    inotify-tools # File system monitoring

    # Development Libraries
    dart-sass # Sass compiler
    gtksourceview3 # Text editor widget
    libsoup_3 # HTTP library
  ];
}

