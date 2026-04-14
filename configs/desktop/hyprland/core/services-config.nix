{ config, pkgs, lib, ... }:
{
  # Notification daemon — required for libnotify (poweralertd, scripts). Stylix themes it via targets.mako.
  services.mako.enable = true;

  # HM default runs `makoctl reload` on config change; during `nixos-rebuild`/`hm switch` there is often no
  # Mako on the session bus yet → D-Bus noise: UnknownMethod /fr/emersion/Mako. Reload only when the unit is up.
  xdg.configFile."mako/config".onChange = lib.mkForce ''
    if [ -n "''${WAYLAND_DISPLAY:-}" ] && ${pkgs.systemd}/bin/systemctl --user is-active --quiet mako.service 2>/dev/null; then
      ${pkgs.mako}/bin/makoctl reload 2>/dev/null || true
    fi
  '';

  systemd.user.services.mako = {
    Unit = {
      Description = "mako notification daemon";
      PartOf = [ config.wayland.systemd.target ];
      After = [ config.wayland.systemd.target ];
      Before = [ "poweralertd.service" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.mako}/bin/mako";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ config.wayland.systemd.target ];
    };
  };

  # System services
  services.blueman-applet.enable = true;

  services.cliphist = {
    enable = true;
    allowImages = true;
    systemdTargets = [ "hyprland-session.target" ];
    extraOptions = [
      "-max-items"
      "100"
    ];
  };

  # gnome-keyring disabled: KeePassXC owns both the SSH agent and the
  # Freedesktop Secret Service API. Keeping gnome-keyring running (even with
  # no components) triggers a warning in KeePassXC and risks SSH_AUTH_SOCK hijack.
  services.gnome-keyring.enable = false;

  services.poweralertd.enable = true;
  # Skip startup broadcast; run after mako so libnotify has a D-Bus target ("Transport endpoint is not connected").
  systemd.user.services.poweralertd = {
    Unit.After = [ "mako.service" ];
    Service.ExecStart = lib.mkForce "${pkgs.poweralertd}/bin/poweralertd -s";
  };
  services.network-manager-applet.enable = true;

  # Polkit agent (required for GUI auth prompts e.g., udisks mounts in Thunar)
  services.polkit-gnome.enable = true;

  # MPD (Music Player Daemon) as a user service for rmpc/kew
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    network = {
      listenAddress = "127.0.0.1";
      port = 6600;
    };
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire Output"
      }
      restore_paused "yes"
      auto_update "yes"
    '';
  };

  # Expose MPD to MPRIS so Hyprpanel can read it via playerctl
  services.mpdris2.enable = true;

}
