{ pkgs, inputs, ... }:
let
  variables = import ../variables.nix { inherit pkgs inputs; };
in
{
  imports = [
    ./waybar.nix
    ./sway-notification-center.nix
    ./wofi.nix
    ./sherlock.nix
    (import ./swww.nix { inherit pkgs variables; })
  ];
}
