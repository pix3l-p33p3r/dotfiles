{ config, inputs, wallpaper, pkgs, lib, ... }@all: {
  imports = [
    ../../configs/desktop/hyprland
    ../../configs/editors/cursor-config.nix
    ../../configs/productivity/task-timewarrior.nix
    ../../configs/terminal/tmux.nix
    ../../configs/security/pkgs.nix
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

  # Remove legacy backups that block xdg.mimeApps from updating mimeapps.list
  home.activation.removeLegacyMimeappsBackup =
    lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      backup="${config.xdg.configHome}/mimeapps.list.backup"
      if [ -e "$backup" ]; then
        rm -f "$backup"
      fi
    '';

  # Faster shutdown of user services to avoid long stop jobs
  xdg.configFile."systemd/user.conf.d/10-timeouts.conf".text = ''
    [Manager]
    DefaultTimeoutStopSec=10s
  '';

  # Provide minimal hypridle config to prevent crash loops on shutdown
  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
      lock_cmd =
      before_sleep_cmd =
      after_sleep_cmd =
      ignore_dbus_inhibit = true
    }
  '';

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

  home.username = "pixel-peeper";
  home.homeDirectory = "/home/pixel-peeper";
  home.stateVersion = "25.05";
}
