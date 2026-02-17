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

    settings = {
      mgr = {
        show_hidden = false;
        sort_by = "natural";
        sort_dir_first = true;
      };
    };
  };

  # Catppuccin Mocha theme for yazi
  xdg.configFile."yazi/theme.toml".source = lib.mkForce "${catppuccinYazi}/mocha/catppuccin-mocha-lavender.toml";

  # Yazi opener configuration (separate from theme)
  xdg.configFile."yazi/yazi.toml".text = ''
    [opener]
    # Define how to open PDFs
    pdf = [
      { run = 'zathura "$@"', orphan = true, desc = "Open in Zathura" }
    ]
    
    # Text files
    text = [
      { run = 'nvim "$@"', block = true, desc = "Edit in Neovim" }
    ]

    # Markdown (preview in terminal with glow)
    markdown = [
      { run = 'glow "$@"', block = true, desc = "Preview with glow" }
    ]
    
    # Images
    image = [
      { run = 'imv "$@"', orphan = true, desc = "Open in imv" }
    ]
    
    # Videos
    video = [
      { run = 'mpv "$@"', orphan = true, desc = "Play in mpv" }
    ]
    
    # Archives
    archive = [
      { run = 'ouch decompress "$@"', desc = "Extract here" }
    ]
    
    # Fallback to xdg-open
    fallback = [
      { run = 'xdg-open "$@"', orphan = true, desc = "Open" }
    ]

    [open]
    # Rules for file types
    rules = [
      { mime = "application/pdf", use = "pdf" },
      { mime = "application/epub+zip", use = "pdf" },
      { mime = "text/markdown", use = "markdown" },
      { mime = "text/*", use = "text" },
      { name = "*.md", use = "markdown" },
      { mime = "image/*", use = "image" },
      { mime = "video/*", use = "video" },
      { mime = "audio/*", use = "video" },
      { mime = "inode/directory", use = "text" },
      { mime = "application/{zip,gzip,x-tar,x-bzip*,x-7z-compressed,x-rar}", use = "archive" },
      { mime = "*", use = "fallback" }
    ]
  '';
}

