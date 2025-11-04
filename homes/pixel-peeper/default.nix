{ inputs, wallpaper, pkgs, lib, ... }@all: {
  imports = [
    ../../configs/desktop/hyprland
    ../../configs/editors/cursor-config.nix
    ../../configs/terminal/tmux.nix
    ./catppuccin.nix
    ./sops.nix
  ];

  # Essential for Thunar for trash, network, and mounting
  # services.gvfs.enable = true; this was the old way 
  xdg.portal.enable = true;

  programs.zsh.enable = true;

  programs.nix-search-tv.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Required for home-manager nix configuration
  nix.package = lib.mkDefault pkgs.nix;

  programs.atuin.enable = true;
  programs.home-manager.enable = true;

  # Zen Browser (twilight) enabled; Firefox remains default browser
  programs.zen-browser = {
    enable = true;
    # No spaces/containers for now
    profiles.default = {
      # TODO: add extensions via extensions.packages once source list is decided
      extensions.packages = [];
    };
  };

  # Install Cursor AI Editor v2.0.34 (using custom AppImage wrapper)
  home.packages = [
    (pkgs.callPackage ../../configs/editors/cursor.nix {})
  ];

  # Minimal themed configs for Taskwarrior / Timewarrior
  home.file = {
    ".taskrc".text = ''
      # Taskwarrior basic settings
      confirmation=no
      dateformat=y-M-d
      weekstart=Monday
      color=on
      # Catppuccin-ish colors
      color.overdue=bold red
      color.due=yellow
      color.blocking=bright cyan
      color.tagged=magenta
      color.pri.H=bold bright red
      color.pri.M=bold yellow
      color.pri.L=bold green
    '';

    ".timewarrior/config".text = ''
      # Timewarrior configuration
      verbose = yes
      month.letters = 3
      confirmation = no
      colors = on
      theme.colors = 256
      reports.day.range = day
      reports.week.range = week
      reports.month.range = month
      summary.ids = off
    '';
  };

  home.username = "pixel-peeper";
  home.homeDirectory = "/home/pixel-peeper";
  home.stateVersion = "25.05";
}
