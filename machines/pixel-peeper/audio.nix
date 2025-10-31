{ config, pkgs, lib, ... }:

{
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
}

