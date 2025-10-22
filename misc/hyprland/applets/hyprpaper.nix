{ pkgs, config, variables }:
let
  writeShellScriptBin = pkgs.stdenv.mkDerivation {
    name = "reload-wallpaper";
    src = ../scripts;
    buildPhase = "";
    installPhase = ''
      mkdir -p $out/bin
      cp $src/reload-wallpaper $out/bin
    '';
  };

in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "~/Pictures/Wallpapers"
      ];
      wallpaper = [
        ",~/Pictures/Wallpapers"
      ];
    };
  };

<<<<<<< HEAD:misc/hyprland/applets/hyprpaper.nix
  systemd.user.services.hyprpaper-wallpaper-reload = {
=======
  # Set initial wallpaper
  systemd.user.services.swww-set-wallpaper = {
    Install = {
      WantedBy = [ config.wayland.systemd.target ];
    };

    Unit = {
      ConditionEnvironment = "WAYLAND_DISPLAY";
      Description = "Set Hellsing wallpaper";
      After = [ config.wayland.systemd.target "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.swww}/bin/swww img --filter Nearest ${variables.wallpaper}";
      Type = "oneshot";
    };
  };

  systemd.user.services.swww-wallpaper-reload = {
>>>>>>> 84798cdf678c72f09e8db6c6ed90b09886eec420:misc/hyprland/applets/swww.nix
    Install = {
      WantedBy = [ config.wayland.systemd.target ];
    };

    Unit = {
      ConditionEnvironment = "WAYLAND_DISPLAY";
      Description = "hyprpaper-wallpaper-reload";
      After = [ config.wayland.systemd.target ];
      PartOf = [ config.wayland.systemd.target ];
    };

    Service = {
      ExecStart = "${writeShellScriptBin}/bin/reload-wallpaper";
    };
  };
}
