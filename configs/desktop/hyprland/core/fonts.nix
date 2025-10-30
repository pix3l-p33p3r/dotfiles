{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Base Noto family
    noto-fonts
    noto-fonts-cjk-sans
    
    # Emoji support
    nerd-fonts.noto              # Nerd Fonts patched Noto with emoji
    
    # Adobe Source Han fonts (CJK coverage)
    source-han-sans
  source-han-serif
    
    # System & icon fonts
    cantarell-fonts
    font-awesome
    
    # Nerd Fonts (development environments)
    nerd-fonts.fira-code         # Terminal
    nerd-fonts.jetbrains-mono    # Code editor
    nerd-fonts.iosevka           # Obsidian notes
    
    # Technical drawing & documentation
    liberation_ttf               # Arial/Times alternatives
    dejavu_fonts                 # Engineering symbols
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      # Nerd Fonts emoji support
      emoji = [ "Noto Nerd Font" ];
      
      # Code editor: JetBrainsMono
      monospace = [
        "JetBrainsMono Nerd Font"
        "Noto Naskh Arabic UI"
        "Noto Sans Arabic"
      ];
      
      # Technical docs: Noto Serif primary
      serif = [
        "Noto Serif"
        "Liberation Serif"         # Times New Roman alternative
        "Noto Naskh Arabic UI"
        "Noto Serif Arabic"
      ];
      
      # Blog/website: Noto Sans
      sansSerif = [
        "Noto Sans"
        "Cantarell"                # GNOME UI fallback
        "Liberation Sans"          # Arial alternative
        "Noto Naskh Arabic UI"
        "Noto Sans Arabic"
      ];
    };
  };
}