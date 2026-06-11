# Android app emulation via Waydroid (LXC container + Wayland).
# Hyprland session already sets NIXOS_OZONE_WL; Intel Iris Xe handles GLES.
#
# First-time setup (after nixos-rebuild switch):
#   sudo waydroid init              # FOSS image, no Play Store
#   sudo waydroid init -s GAPPS     # + Google Play (optional)
#   waydroid session start
#   waydroid show-full-ui
#
# Or: ~/dotfiles/scripts/waydroid-setup.sh

{ config, pkgs, lib, ... }:

{
  virtualisation.waydroid = {
    enable = true;
    # nftables backend is active on alucard; nixpkgs picks waydroid-nftables.
  };

  # Android apps render as normal Wayland windows in Hyprland.
  # Full UI / settings: float; installed apps: tile like native apps.
  # (Class names vary by APK — adjust with `hyprctl clients` if needed.)
}
