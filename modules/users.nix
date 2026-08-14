{ pkgs, ... }:
{
  users.defaultUserShell = pkgs.zsh;
  environment.shells = [ pkgs.zsh ];

  users.users.pixel-peeper = {
    isNormalUser = true;
    description = "pixel-peeper";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "audio" "docker" "video" ];
  };

  security.sudo.wheelNeedsPassword = true;
}
