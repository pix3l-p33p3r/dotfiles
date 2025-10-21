{ pkgs, ... }:
{
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome
    source-han-sans
    source-han-sans-japanese
    source-han-serif-japanese
    cantarell-fonts
    font-awesome
    noto-fonts-emoji
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [
        "JetBrainsMono Nerd Font"
        "Noto Naskh Arabic UI"
        "Noto Sans Arabic"
      ];
      serif = [
        "Noto Serif"
        "Noto Naskh Arabic UI"
        "Noto Sans Arabic"
      ];
      sansSerif = [
        "Noto Sans"
        "Noto Naskh Arabic UI"
        "Noto Sans Arabic"
      ];
    };
  };
}
