{ pkgs, ... }:
{
  home.username = "pixel-peeper";
  home.homeDirectory = "/home/pixel-peeper";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
  programs.zsh.enable = true;
  programs.git.enable = true;
  programs.firefox.enable = true;

  programs.foot.enable = true;
  programs.foot.settings.main.term = "xterm-256color";

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      monitor = [ "eDP-1,1920x1080@60,0x0,1" ];
      "$mod" = "SUPER";
      exec-once = [
        "wayle"
        "hypridle"
        "hyprpaper"
      ];
      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "rgb(89b4fa)";
        "col.inactive_border" = "rgb(313244)";
      };
      decoration = {
        rounding = 6;
        blur.enabled = false;
        shadow.enabled = false;
      };
      animations.enabled = false;
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
      };
      bind = [
        "$mod, RETURN, exec, foot"
        "$mod, D, exec, fuzzel"
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        "$mod, ESCAPE, exec, hyprlock"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, L, movewindow, r"
        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "hyprlock";
        before_sleep_cmd = "hyprlock";
      };
      listener = [
        { timeout = 300; on-timeout = "hyprlock"; }
        { timeout = 600; on-timeout = "systemctl suspend"; }
      ];
    };
  };

  programs.hyprlock.enable = true;

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "${../assets/wallpapers/alucard.jpg}" ];
      wallpaper = [ "eDP-1,${../assets/wallpapers/alucard.jpg}" ];
    };
  };

  services.wayle = {
    enable = true;
    autoInstallDependencies = true;
    settings = {
      bar.layout = [
        {
          monitor = "eDP-1";
          show = true;
          left = [ "workspaces" ];
          center = [ "clock" ];
          right = [ "volume" "battery" "network" ];
        }
      ];
      modules.clock.format = "%H:%M";
      osd.monitor = "eDP-1";
    };
  };

  home.packages = with pkgs; [
    google-chrome
    mullvad-browser
    keepassxc
    sops
    age
    gnupg
    git
    gh
    ripgrep
    fd
    fzf
    bat
    eza
    zoxide
    tmux
    neovim
    yazi
    btop
    foot
    fuzzel
    wl-clipboard
    grim
    slurp
    hyprshot
    pavucontrol
    playerctl
    brightnessctl
    gcc
    gnumake
    rustc
    cargo
    zig
    nasm
    python3
    docker-compose
    code-cursor
  ];
}
