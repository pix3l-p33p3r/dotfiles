# ThinkPad T14s Gen 2i (20WNS1R800) — Tiger Lake + Iris Xe (i915).
# Mirrors the proposed nixos-hardware profile
# nixosModules.lenovo-thinkpad-t14s-intel-gen2 (branch add-thinkpad-t14s-intel-gen2).
# tiger-lake sets hardware.intelgpu.vaapiDriver = "intel-media-driver" (iHD only).
{ inputs, lib, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14s
    (inputs.nixos-hardware + "/common/cpu/intel/tiger-lake")
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  hardware.trackpoint = {
    enable = true;
    emulateWheel = true;
  };

  services.hardware.bolt.enable = true;

  boot.kernelParams = [
    "mem_sleep_default=deep"
    "i915.enable_psr=0"
    "i2c_designware.timeout_ms=1000"
  ];

  services.thermald.enable = lib.mkDefault false;
  services.throttled.enable = lib.mkDefault false;
  services.fprintd.enable = false;
}
