{ ... }:
{
  imports = [
    ./waybar.nix
    ./sway-notification-center.nix
    ./wofi.nix
    # ./sherlock.nix  # Temporarily disabled due to module structure change
    ./swww.nix
  ];
}
