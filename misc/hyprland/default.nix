{pkgs, inputs, ...}:
{
  imports = [

    inputs.stylix.homeModules.stylix

    # import home manager custom modules
    # ../../../../modules/hm

    # ../../common

    # Hyprland config
    ./hyprland.nix

    # Fonts and GTK theming
    ./fonts.nix
    ./theming.nix

    # XDG stuff
    ./xdg.nix

    # Applets
    ./applets

    # Packages
    ./pkgs.nix

    # ./browsers/firefox.nix
    ./kitty.nix
    ./zsh
    ./mpv.nix
    ./imv.nix
    ./zathura.nix

    ./nvim
  ];

}

