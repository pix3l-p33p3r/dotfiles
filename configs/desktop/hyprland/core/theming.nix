{ pkgs, lib, ... }:
{
  home.pointerCursor = {
    x11 = {
      enable = true;
      defaultCursor = "volantes_cursors";
    };
  };

  gtk = {
    enable = true;
    cursorTheme = {
      size = 24;
      name = "volantes_cursors";
      package = pkgs.volantes-cursors;
    };

    iconTheme = {
      package = pkgs.catppuccin-papirus-folders;
       name = "Papirus";
     };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

   stylix = {
     enable = true;
 
    #  targets.neovim.enable = true;
     targets.qt.enable = true;
 
     cursor.name = "volantes_cursors";
     cursor.size = 42;
     cursor.package = pkgs.volantes-cursors;
 
     fonts.monospace = {
       name = "JetBrainsMono Nerd Font";
       package = pkgs.nerd-fonts.jetbrains-mono;
     };
 
    fonts.sansSerif = {
      name = "JetBrainsMono Nerd Font";
      package = pkgs.nerd-fonts.jetbrains-mono;
    };

    fonts.serif = {
      name = "JetBrainsMono Nerd Font";
      package = pkgs.nerd-fonts.jetbrains-mono;
    };
 
     fonts.sizes.applications = 11;



     polarity = "dark";

     base16Scheme = {
      base00 = "1e1e2e"; # base
      base01 = "181825"; # mantle
      base02 = "313244"; # surface0
      base03 = "45475a"; # surface1
      base04 = "585b70"; # surface2
      base05 = "cdd6f4"; # text
      base06 = "f5e0dc"; # rosewater
      base07 = "b4befe"; # lavender
      base08 = "f38ba8"; # red
      base09 = "fab387"; # peach
      base0A = "f9e2af"; # yellow
      base0B = "a6e3a1"; # green
      base0C = "94e2d5"; # teal
      base0D = "89b4fa"; # blue
      base0E = "b4befe"; # lavender
      base0F = "f2cdcd"; # flamingo
};

     #targets.firefox.profileNames = [ "orbit" ];
   };
}
