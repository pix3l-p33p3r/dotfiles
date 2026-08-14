{ pkgs, lib, ... }:
{
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  boot.lanzaboote.enable = true;
  boot.lanzaboote.pkiBundle = "/var/lib/sbctl";

  environment.systemPackages = [ pkgs.sbctl ];

  boot.plymouth = {
    enable = true;
    theme = "catppuccin-mocha";
    themePackages = [ (pkgs.catppuccin-plymouth.override { variant = "mocha"; }) ];
  };

  boot.initrd.systemd.enable = true;
  boot.initrd.verbose = false;
  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = [ "-3" "-T0" ];
  boot.initrd.supportedFilesystems = [ "btrfs" "vfat" ];
  boot.initrd.systemd.tpm2.enable = true;

  boot.consoleLogLevel = 0;
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "systemd.show_status=false"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "video=eDP-1:1920x1080@60"
    "i915.enable_psr=0"
    "8250.nr_uarts=0"
    "nowatchdog"
    "nmi_watchdog=0"
  ];

  boot.blacklistedKernelModules = [ "dccp" "sctp" "rds" "tipc" "vivid" ];

  systemd.services.fwupd.wantedBy = lib.mkForce [];
  systemd.services.fwupd-refresh.wantedBy = lib.mkForce [];
}
