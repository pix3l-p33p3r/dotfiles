{ config, pkgs, lib, ... }:
let
  bootstrap = ../bootstrap;
  zshConfig = ../../../configs/terminal/zsh/config;
  zshPlugins = pkgs.callPackage ../../../configs/terminal/zsh/plugins.nix { };
  # Host zsh reads ~/.config/zsh before nix-enter, so it is a real copy too.
  zshConfigFiles = lib.listToAttrs (
    map (p: {
      name = ".config/zsh/" + lib.removePrefix "${toString zshConfig}/" (toString p);
      value.source = p;
    }) (lib.filesystem.listFilesRecursive zshConfig)
  );
  bin = name: source: {
    ".local/bin/${name}" = {
      inherit source;
      executable = true;
    };
  };
in
{
  # NEVER programs.kitty.enable. Kitty starts outside nix-user-chroot.
  # home.file / programs.kitty write /nix/store symlinks, which Kitty cannot
  # read on the host — that drops the theme. Edit modules/kitty.conf instead.
  assertions = [
    {
      assertion = config.programs.kitty.enable == false;
      message = "programs.kitty.enable is forbidden on this cluster. It replaces kitty.conf with a /nix/store symlink and wipes the theme. Edit homes/elel-yak/modules/kitty.conf.";
    }
    {
      assertion = lib.hasInfix "include current-theme.conf" (builtins.readFile ./kitty.conf);
      message = "modules/kitty.conf must keep `include current-theme.conf` (Catppuccin theme).";
    }
    {
      assertion = lib.hasInfix "hwdec=auto-copy" (builtins.readFile ./mpv.conf);
      message = "modules/mpv.conf must keep `hwdec=auto-copy`.";
    }
  ];

  home.hostFiles =
    zshConfigFiles
    // {
      ".config/zsh/plugins.zsh".source = zshPlugins.init;
      ".zshenv".source = ./zshenv;
      ".config/kitty/kitty.conf".source = ./kitty.conf;
      ".config/mpv/mpv.conf".source = ./mpv.conf;
      ".xprofile".source = bootstrap + "/xprofile";
      ".config/environment.d/999-local-bin.conf".source = bootstrap + "/local-bin.conf";
      ".config/systemd/user/goinfre-heal.service".source = bootstrap + "/goinfre-heal.service";
    }
    // bin "nix-enter" (bootstrap + "/nix-enter")
    // bin "nix-setup" (bootstrap + "/nix-setup")
    // bin "goinfre-heal" (bootstrap + "/goinfre-heal")
    // bin "nixgl-run" ./nixgl-run.sh
    // bin "kitty" ./kitty-launcher.sh
    // bin "kitten" ./kitten-launcher.sh
    // bin "cursor" ./cursor-launcher.sh
    // bin "cursor-ide" ./cursor-launcher.sh
    // bin "grok-bot" ./grok-bot-launcher.sh
    // bin "yazi" ./yazi-launcher.sh
    // bin "toolchain-gc" ./toolchain-gc.sh;

  # ~/.config/zsh used to be a symlink into the repo; installing files
  # through it would write into the working tree.
  home.activation.zshConfigDir = lib.hm.dag.entryBetween [ "hostFiles" ] [ "linkGeneration" ] ''
    if [[ -L "$HOME/.config/zsh" ]]; then
      run rm -f "$HOME/.config/zsh"
    fi
  '';

  home.activation.goinfreHealUnit = lib.hm.dag.entryAfter [ "hostFiles" ] ''
    units="$HOME/.config/systemd/user"
    run mkdir -p "$units/graphical-session.target.wants"
    run ln -sfn "$units/goinfre-heal.service" "$units/graphical-session.target.wants/goinfre-heal.service"
    if [[ -x /usr/bin/systemctl ]] && /usr/bin/systemctl --user show-environment >/dev/null 2>&1; then
      run /usr/bin/systemctl --user daemon-reload
    fi
  '';

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
