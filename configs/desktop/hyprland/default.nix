{
  pkgs,
  inputs,
  host,
  wallpaper,
  ...
}:
{

  imports = [
    inputs.stylix.homeModules.stylix

    # Hyprland config
    ./core/hyprland.nix

    # Fonts and GTK theming
    ./core/fonts.nix
    ./core/theming.nix

    # XDG stuff
    ./core/xdg.nix

    # Applets
    ./apps/applets

    # Packages
    ./core/pkgs.nix

    # Browsers
    # ../../browsers/firefox.nix

    # Terminal
    ../../terminal/kitty.nix
    ../../terminal/zsh
    # ../../terminal/fastfetch.nix
    
    # Neovim
    ../../terminal/nvim

    # Media
    ../../media/mpv.nix
    ../../media/zathura.nix
    ../../media/rmpc.nix

    # Desktop apps
    ./apps/imv.nix


  ];

}

