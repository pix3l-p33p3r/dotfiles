{ pkgs, lib, ... }:
let
  catppuccinYazi = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "yazi";
    rev = "4da08049c135b406ddaaafb0c8eb4201d7da866e";
    sha256 = "sha256-VQLbBn8pP1SXs2/lNDlp/ILfDz29J/qN9EkP2hKQDdU=";
  };
in
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    
    settings = {
      manager = {
        show_hidden = false;
        sort_by = "natural";
        sort_dir_first = true;
      };
    };
  };

  # Catppuccin Mocha theme for yazi
  xdg.configFile."yazi/theme.toml".source = "${catppuccinYazi}/mocha/catppuccin-mocha-lavender.toml";

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
      { mime = "text/*", use = "text" },
      { mime = "image/*", use = "image" },
      { mime = "video/*", use = "video" },
      { mime = "audio/*", use = "video" },
      { mime = "inode/directory", use = "text" },
      { mime = "application/{zip,gzip,x-tar,x-bzip*,x-7z-compressed,x-rar}", use = "archive" },
      { mime = "*", use = "fallback" }
    ]
  '';
}

