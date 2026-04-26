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
    ../../configs/browsers/librewolf.nix
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

  programs.zsh.enable = true;
  programs.nix-search-tv.enable = true;

  nixpkgs.config.allowUnfree = true;

  nix.package = lib.mkDefault pkgs.nix;

  # Nix 2.31.x bug: a trusted user's extra-trusted-public-keys replaces rather
  # than supplements the daemon's system keys. Repeating all keys here ensures
  # the full set is always active via ~/.config/nix/nix.conf.
  nix.settings.extra-trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
    "zen-browser.cachix.org-1:z/QLGrEkiBYF/7zoHX1Hpuv0B26QrmbVBSy9yDD2tSs="
  ];

  programs.atuin.enable = true;
  programs.home-manager.enable = true;

  # Use 'nix profile add' instead of the deprecated 'nix profile install' alias.
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

  # Prevents xdg.mimeApps from blocking on a legacy backup file.
  home.activation.removeLegacyMimeappsBackup =
    lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      backup="${config.xdg.configHome}/mimeapps.list.backup"
      if [ -e "$backup" ]; then
        rm -f "$backup"
      fi
    '';

  # Keep stop jobs short to avoid hanging on shutdown.
  xdg.configFile."systemd/user.conf.d/10-timeouts.conf".text = ''
    [Manager]
    DefaultTimeoutStopSec=10s
  '';

  home.packages = [
    cursorPkg
    pkgs.zed-editor
    pkgs.sl
  ];

  home.username = "pixel-peeper";
  home.homeDirectory = "/home/pixel-peeper";
  home.stateVersion = "25.05";
}
