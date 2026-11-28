{ pkgs, lib, ... }:
let
  catppuccinYazi = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "yazi";
    rev = "main";
    sha256 = "sha256-zkL46h1+U9ThD4xXkv1uuddrlQviEQD3wNZFRgv7M8Y=";
  };
in
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";

    extraPackages = with pkgs; [
      glow
      jq
      ouch
      pandoc # EPUB text preview via piper
    ];

    plugins = {
      piper = pkgs.yaziPlugins.piper;
      git = {
        package = pkgs.yaziPlugins.git;
        setup = true;
      };
      # entry-only plugin — no :setup()
      lazygit = pkgs.yaziPlugins.lazygit;
      gif-preview = ./yazi-plugins/gif-preview.yazi;
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          on = [ "g" "g" ];
          run = "plugin lazygit";
          desc = "lazygit";
        }
        {
          on = [ "z" ];
          run = "shell --block --confirm -- bash -lc 'ya emit cd \"$(zoxide query -i)\"'";
          desc = "zoxide jump";
        }
        {
          on = [ "C" ];
          run = ''shell -- kitten clipboard < "$0"'';
          desc = "copy file via kitten";
        }
      ];
    };

    settings = {
      # parent | current | preview  (fractions of width; default [1,4,3])
      # Change these numbers to resize panes permanently.
      # In-session: drag the separators with the mouse (yazi ≥26 drag).
      mgr = {
        ratio = [
          1
          2
          5
        ];
        show_hidden = false;
        sort_by = "natural";
        sort_dir_first = true;
      };

      preview = {
        max_width = 1200;
        max_height = 1600;
        image_filter = "triangle";
      };

      plugin = {
        prepend_previewers = [
          {
            url = "*.md";
            run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'';
          }
          {
            url = "*.markdown";
            run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'';
          }
          {
            url = "*.json";
            run = ''piper -- jq -C . "$1"'';
          }
          # GIF: autoplay in the preview pane (no key). Built-in image preview is still-only.
          {
            mime = "image/gif";
            run = "gif-preview";
          }
          {
            url = "*.gif";
            run = "gif-preview";
          }
          # EPUB: no built-in previewer — text extract via pandoc
          {
            mime = "application/epub+zip";
            run = ''piper -- pandoc -f epub -t plain --wrap=auto "$1"'';
          }
          {
            url = "*.epub";
            run = ''piper -- pandoc -f epub -t plain --wrap=auto "$1"'';
          }
          # image/*: built-in kitty graphics — never `run = "kitten …"` (plugin name)
        ];
      };

      opener = {
        pdf = [
          {
            run = ''xdg-open "$@"'';
            orphan = true;
            desc = "Open";
          }
        ];
        epub = [
          {
            run = ''xdg-open "$@"'';
            orphan = true;
            desc = "Open";
          }
        ];
        text = [
          {
            run = ''nvim "$@"'';
            block = true;
            desc = "Edit in Neovim";
          }
        ];
        markdown = [
          {
            run = ''glow -p "$@"'';
            block = true;
            desc = "Preview with glow";
          }
          {
            run = ''nvim "$@"'';
            block = true;
            desc = "Edit in Neovim";
          }
        ];
        image = [
          {
            run = ''xdg-open "$@"'';
            orphan = true;
            desc = "Open";
          }
        ];
        video = [
          {
            run = ''mpv "$@"'';
            orphan = true;
            desc = "Play in mpv";
          }
        ];
        archive = [
          {
            run = ''ouch decompress "$@"'';
            desc = "Extract here";
          }
        ];
        fallback = [
          {
            run = ''xdg-open "$@"'';
            orphan = true;
            desc = "Open";
          }
        ];
      };

      open = {
        rules = [
          {
            mime = "application/pdf";
            use = "pdf";
          }
          {
            mime = "application/epub+zip";
            use = "epub";
          }
          {
            url = "*.epub";
            use = "epub";
          }
          {
            url = "*.md";
            use = "markdown";
          }
          {
            url = "*.markdown";
            use = "markdown";
          }
          {
            mime = "text/markdown";
            use = "markdown";
          }
          {
            mime = "text/*";
            use = "text";
          }
          {
            mime = "image/*";
            use = "image";
          }
          {
            mime = "video/*";
            use = "video";
          }
          {
            mime = "audio/*";
            use = "video";
          }
          {
            mime = "inode/directory";
            use = "text";
          }
          {
            mime = "application/{zip,gzip,x-tar,x-bzip*,x-7z-compressed,x-rar}";
            use = "archive";
          }
          {
            url = "*";
            use = "fallback";
          }
        ];
      };
    };
  };

  # Catppuccin Mocha theme for yazi
  xdg.configFile."yazi/theme.toml".source = lib.mkForce "${catppuccinYazi}/mocha/catppuccin-mocha-lavender.toml";
}
