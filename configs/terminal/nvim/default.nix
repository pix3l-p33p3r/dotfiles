{ pkgs, ... }:
{
  home.packages = with pkgs; [ neovide ];

  xdg.configFile."nvim/parser".source = "${
    pkgs.symlinkJoin {
      name = "treesitter-parsers";
      paths =
        (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
          p.asm
          p.bash
          p.c
          p.cpp
          p.css
          p.csv
          p.diff
          p.dockerfile
          p.gitattributes
          p.gitcommit
          p.git_config
          p.gitignore
          p.go
          p.goctl
          p.gomod
          p.gosum
          p.html
          p.ini
          p.javascript
          p.jsdoc
          p.json
          p.just
          p.latex
          p.linkerscript
          p.lua
          p.make
          p.markdown
          p.nasm
          p.nginx
          p.objdump
          p.passwd
          p.proto
          p.python
          p.regex
          p.rust
          p.scss
          p.ssh_config
          p.strace
          p.toml
          p.tsx
          p.typescript
          p.udev
          p.vim
          p.vimdoc
          p.vue
          p.xml
          p.yaml
        ])).dependencies;
    }
  }/parser";

  programs.neovim = {
    enable = true;

    extraPackages = with pkgs; [
      # ============================================================================
      # |                            ESSENTIAL TOOLS                              |
      # ============================================================================
      # Core Development
      gcc # C/C++ compiler
      gnumake # Build automation tool
      tree-sitter # Parser generator
      inotify-tools # File system monitoring
      nodejs
      git
      cargo
      ripgrep

      # ============================================================================
      # |                          LANGUAGE SERVERS                               |
      # ============================================================================
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

      # ============================================================================
      # |                            FORMATTERS                                   |
      # ============================================================================
      nixfmt # Nix formatter
      nodePackages.prettier # JavaScript/TypeScript formatter
      prettierd # Prettier daemon
      black # Python formatter
      stylua # Lua formatter
      rustfmt # Rust formatter
    ];
  };

  home.file.".config/nvim" = {
    source = ./conf;
    recursive = true;
  };
}