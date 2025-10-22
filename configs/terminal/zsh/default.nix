{ pkgs, ... }:
{
  home.packages = with pkgs; [
    #
  ];

  programs.zsh.enable = true;

  home.sessionVariables = {
    ZDOTDIR = "$HOME/.config/zsh";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.file = {
    ".config/zsh" = {
      source = ./config;
      recursive = true;
    };
  };
}
