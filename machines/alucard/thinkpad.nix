# ThinkPad T14s Gen 2i (20WNS1R800) — Tiger Lake + Iris Xe (i915).
# Mirrors the proposed nixos-hardware profile
# nixosModules.lenovo-thinkpad-t14s-intel-gen2 (branch add-thinkpad-t14s-intel-gen2).
# tiger-lake sets hardware.intelgpu.vaapiDriver = "intel-media-driver" (iHD only).
#
# Firmware/POST: ~10s is normal for this chassis on Linux (see sibling T14
# Gen 2i probes ~10.7s firmware). Fast Boot / unused devices already applied;
# remaining time is Lenovo UEFI + Intel ME + TPM, not the OS.
#
# Sleep: mem_sleep_default=deep only works if EFI Config → Power → Sleep State
# is "Linux" so ACPI advertises S3. If `cat /sys/power/mem_sleep` is just
# "s2idle" (no [deep]), the firmware is in Windows/Linux (S0ix) mode and
# failed s2idle resumes show up in `last` as crash.
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
