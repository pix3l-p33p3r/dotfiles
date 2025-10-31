{ config, pkgs, lib, ... }:

{

  # ───── Enable VA-API + Vulkan ─────
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };


# --- Updates & maintenance ---

# Automatically update the NixOS system configuration
 system.autoUpgrade = {
    enable = true; # Enable automatic system upgrades
    allowReboot = false; # Do NOT automatically reboot the system after an upgrade
    flake = "/home/pixel-peeper/wow#nixos"; # Specify the Flake to use for the upgrade (e.g., your local config)
    dates = "daily"; # Run the automatic upgrade process daily
 };

# Garbage Collection settings for the Nix Store
  nix.gc = {
    automatic = true; # Enable automatic Garbage Collection
    dates = "weekly"; # Run GC weekly

# Options passed to the 'nix store gc' command. Deletes old generations/files
# that haven't been referenced for more than 20 days.
    options = "--delete-older-than 20d"; 
  };

# Optimization of the Nix store
  nix.optimise = {
  automatic = true; # Enable automatic optimization

# Optimization performs hard-linking of identical files in the Nix store 
# to save disk space.
  dates = ["weekly"]; # Run optimization weekly
 };

  # ───── X11 (required for some compatibility) ─────
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ───── Wayland Compositor ─────
  programs.hyprland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ 
      xdg-desktop-portal-hyprland 
      xdg-desktop-portal-gtk
    ];
  };

  # ───── Security & PAM ─────
  security.pam.services.hyprlock = {};


  # ───── DCONF & GSETTINGS ─────
  programs.dconf.enable = true;
  services.dbus.enable = true;

  # ───── Audio (Pipewire) ─────
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = lib.mkForce true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };
  security.rtkit.enable = true;
  hardware.alsa.enable = true;

  # ───── Bluetooth ─────
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  programs.nm-applet = {
    enable = true;
    indicator = true;
};

}
