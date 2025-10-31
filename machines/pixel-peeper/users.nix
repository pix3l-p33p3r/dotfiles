{ config, pkgs, ... }:

{
  # ───── Shell & User ─────
  # Default Shell
  users.defaultUserShell = pkgs.zsh;

  environment.shells = with pkgs; [ zsh ];
  programs.zsh.enable = true;

  users.users.pixel-peeper = {
    isNormalUser = true;
    description = "pixel-peeper";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "audio" ];
  };
}

