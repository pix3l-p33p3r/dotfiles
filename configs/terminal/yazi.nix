{ pkgs, ... }:
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

  # Yazi opener configuration
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

