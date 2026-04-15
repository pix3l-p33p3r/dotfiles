{ config, pkgs, lib, ... }:

{
  networking.hostName = "alucard";

  catppuccin.flavor = "mocha";
  catppuccin.accent = "mauve";

  nixpkgs.config.allowUnfree = true;

  # Do not change after initial install — controls stateful data locations.
  system.stateVersion = "25.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 1401946112; # 1337MB
  # Trust the main user so client-specified caches aren't ignored.
  nix.settings.trusted-users = [ "root" "pixel-peeper" ];

  nix.settings.max-jobs = "auto";
  nix.settings.cores = 0;
  nix.settings.auto-optimise-store = true;

  # Give up on unreachable substituters without stalling builds.
  # 15s is needed because DoT DNS resolution counts against this budget --
  # 5s was too tight and caused false timeout warnings on warm caches.
  nix.settings.connect-timeout = 15;

  # Build jobs run at lower priority to keep the desktop responsive.
  nix.daemonCPUSchedPolicy = "batch";
  nix.daemonIOSchedClass   = "idle";

  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://catppuccin.cachix.org"
    "https://nix-community.cachix.org"  # home-manager, sops-nix
    "https://lanzaboote.cachix.org"
    "https://zen-browser.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
    "zen-browser.cachix.org-1:z/QLGrEkiBYF/7zoHX1Hpuv0B26QrmbVBSy9yDD2tSs="
  ];

  # Required for the MCP-NixOS server and other dynamically linked binaries.
  programs.nix-ld.enable = true;

  # wsdd: needed by GVFS for WS-Discovery; silences gvfsd-wsdd warnings.
  environment.systemPackages = [ pkgs.wsdd ];

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi = {
    powersave = false;
    # Randomize MACs during probe scans only (not association); 802.1X APs unaffected.
    scanRandMacAddress = true;
  };

  # Stable per-SSID MAC (opsec + DHCP stability).  Do not set wifi.bgscan here —
  # NetworkManager 1.46+ rejects it in NetworkManager.conf [connection] (unknown key).
  # Tune bgscan per SSID with nmcli if needed: 802-11-wireless.bgscan (keyfile only).
  networking.networkmanager.settings.connection = {
    "wifi.cloned-mac-address" = "stable";
  };

  # Exact name — wildcards are not applied for P2P devices on this NM build.
  networking.networkmanager.unmanaged = [ "interface-name:p2p-dev-wlp0s20f3" ];

  # Prevent rebuilds and boots from stalling while waiting for a connection.
  systemd.services.NetworkManager-wait-online.enable = false;

  # iwlwifi loads very early; modprobe.d alone can leave sysfs at defaults.  Kernel
  # cmdline applies at first bind (verified: bt_coex_active / swcrypto then match).
  boot.kernelParams = [
    "iwlwifi.bt_coex_active=0"
    "iwlwifi.swcrypto=1"
    "iwlwifi.power_save=0"
  ];

  # Belt-and-suspenders for any later modprobe reload path. All `options …`
  # lines live here so we do not rely on cross-file merges (and avoid mkForce
  # dropping iwlwifi tuning). i915 / thinkpad lines: see
  # docs/machines/alucard/HARDWARE-ACCELERATION.md.
  boot.extraModprobeConfig = ''
    options iwlwifi bt_coex_active=0 swcrypto=1 power_save=0
    options i915 enable_guc=3 enable_fbc=1 enable_psr=1
    options thinkpad_acpi experimental=1 fan_control=1
  '';

  boot.kernel.sysctl = {
    "vm.swappiness" = 60;
    "vm.vfs_cache_pressure" = 50;
  };

  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableSystemSlice = true;
    enableUserSlices = true;
  };

  # Weekly TRIM for SSD health.
  services.fstrim.enable = true;

  # /tmp lives in RAM — temp files never touch the NVMe and vanish on reboot.
  boot.tmp.useTmpfs = true;
  boot.tmp.cleanOnBoot = true;
}
