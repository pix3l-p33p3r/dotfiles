{ config, inputs, wallpaper, pkgs, lib, ... }@all:
let
  cursorPkg = pkgs.callPackage ../../configs/editors/cursor.nix {};
in
{
  imports = [
    ../../configs/desktop/hyprland
    ../../configs/editors/cursor-config.nix
    ../../configs/browsers/chrome.nix
    ../../configs/browsers/zen-browser.nix
    ../../configs/productivity/task-timewarrior.nix
    ../../configs/terminal/tmux.nix
    ../../configs/security/pkgs.nix
    ../../configs/security/ssh.nix
    ../../configs/security/keepassxc.nix
    ../../configs/security/gpg.nix
    ../../configs/development/git.nix
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

  # Override home-manager's installPackages to use 'nix profile add' instead of
  # the deprecated 'nix profile install' alias, silencing the upstream warning.
  home.activation.installPackages = lib.mkForce (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    function nixReplaceProfile() {
      local oldNix="$(command -v nix)"
      nixProfileRemove 'home-manager-path'
      run $oldNix profile add $1
    }

    if [[ -e ${config.home.profileDirectory}/manifest.json ]] ; then
      INSTALL_CMD="nix profile add"
      INSTALL_CMD_ACTUAL="nixReplaceProfile"
      LIST_CMD="nix profile list"
      REMOVE_CMD_SYNTAX='nix profile remove {number | store path}'
    else
      INSTALL_CMD="nix-env -i"
      INSTALL_CMD_ACTUAL="run nix-env -i"
      LIST_CMD="nix-env -q"
      REMOVE_CMD_SYNTAX='nix-env -e {package name}'
    fi

    if ! $INSTALL_CMD_ACTUAL ${config.home.path} ; then
      echo
      _iError $'Oops, Nix failed to install your new Home Manager profile!\n\nPerhaps there is a conflict with a package that was installed using\n"%s"? Try running\n\n    %s\n\nand if there is a conflicting package you can remove it with\n\n    %s\n\nThen try activating your Home Manager configuration again.' "$INSTALL_CMD" "$LIST_CMD" "$REMOVE_CMD_SYNTAX"
      exit 1
    fi
    unset -f nixReplaceProfile
    unset INSTALL_CMD INSTALL_CMD_ACTUAL LIST_CMD REMOVE_CMD_SYNTAX
  '');

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

  # Install editors
  home.packages = [
    cursorPkg
    pkgs.zed-editor
  ];

  home.username = "pixel-peeper";
  home.homeDirectory = "/home/pixel-peeper";
  home.stateVersion = "25.05";
}
