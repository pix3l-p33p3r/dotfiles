{ config, pkgs, lib, inputs, self, ... }:

let
  luksDevice = "luks-77036ffc-3333-4526-bbe8-c0a6ca58e92e";
in
{
  # ───── Bootloader configuration ─────
  # Lanzaboote provides an external installer; disable systemd-boot module
  boot.loader.systemd-boot.enable = lib.mkForce false;
  
  # Allows NixOS to manage EFI variables, necessary for systemd-boot to work.
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Faster boot timeout
  boot.loader.timeout = 1;  # 1 second bootloader menu (was default 5)

  # ───── Lanzaboote (Secure Boot with UKI) ─────
  # Builds signed Unified Kernel Images and integrates with systemd-boot.
  boot.lanzaboote.enable = true;

  # Where sbctl will store and read your PK/KEK/db bundle
  # Lanzaboote will automatically sign all kernels during rebuilds using these keys
  boot.lanzaboote.pkiBundle = "/var/lib/sbctl";
  
  # Install sbctl for Secure Boot key management (manual operations)
  environment.systemPackages = with pkgs; [
	sbctl  # Secure Boot key management tool
  ];

  # ───── Firmware updates with fwupd ─────
  
  # Enable fwupd for firmware updates (BIOS, EC, ME, etc.)
  services.fwupd.enable = true;

  # Install firmware packages for Intel microcode
  hardware.enableRedistributableFirmware = true;

  # ───── Plymouth (Graphical Boot Splash) ─────
  
  # Use nixos-catppuccin-plymouth from GitHub
  # Build the theme package from the repository
  nixpkgs.overlays = [
    (self: super: {
      nixos_boot = super.stdenv.mkDerivation rec {
        pname = "nixos_boot";
        version = "0.0.1";
        src = "${inputs.nixos-catppuccin-plymouth}/src/theme";
        
        buildInputs = [ super.git ];
        
        unpackPhase = ''
        '';
        
        configurePhase = ''
          mkdir -p $out/share/plymouth/themes/nixos_boot
        '';
        
        buildPhase = ''
        '';
        
        installPhase = ''
          cp -r *png $out/share/plymouth/themes/nixos_boot
          cp -r nixos_boot.script $out/share/plymouth/themes/nixos_boot
          cp -r nixos_boot.plymouth $out/share/plymouth/themes/nixos_boot
          chmod +x $out/share/plymouth/themes/nixos_boot/nixos_boot.plymouth $out/share/plymouth/themes/nixos_boot/nixos_boot.script
          find $out/share/plymouth -name "*.plymouth" -exec sed -i "s@\/usr\/@$out\/@" {} \;
        '';
      };
    })
  ];
  
  boot.plymouth = {
	enable = true;
	themePackages = [ pkgs.nixos_boot ];
	theme = "nixos_boot";
	extraConfig = ''
	  ShowDelay=0
	  DeviceScale=1.2
	'';
  };
  
  # Disable the catppuccin.plymouth module to avoid conflicts
  catppuccin.plymouth.enable = lib.mkForce false;
  
  # Modern systemd-based initrd with Plymouth support
  boot.initrd = {
	systemd.enable = true;  # Required for Plymouth + systemd-ask-password in initrd
	verbose = false;
	
	# Use zstd for initrd compression (good balance of speed and size)
	# Note: lz4 has compatibility issues with systemd initrd (resolves to dev package)
	# zstd is more reliable and still very fast
	compressor = "zstd";
	
	# Preload Intel graphics driver for Plymouth
	kernelModules = [ "i915" ];
	
	# Filesystem support
	supportedFilesystems = [ "ext4" "vfat" "btrfs" ];
  };

  boot.initrd.luks.devices.${luksDevice} = {
	allowDiscards = true;
	bypassWorkqueues = true;
	preLVM = true;
	crypttabExtraOpts = [
	  "tries=3"
	  "x-systemd.device-timeout=0"
	];
  };

  # ───── Silent Boot Configuration ─────
  
  # Use mkMerge to avoid duplicate attribute definition errors for boot.kernelParams
  boot.kernelParams = lib.mkMerge [
	[
	  # Silent boot - hide boot messages
	  "quiet"           # Reduce boot messages
	  "splash"          # Enable splash screen (Plymouth)
	  "loglevel=3"      # Show only errors (3 = err)

	  # Systemd boot messages
	  "systemd.show_status=false"      # Hide systemd status
	  "rd.systemd.show_status=false"   # Hide systemd status in initrd

	  # Udev messages
	  "rd.udev.log_level=3"  # Reduce udev verbosity in initrd
	  "udev.log_priority=3"  # Reduce udev messages

	  # VGA/Framebuffer - keep current mode for smooth transition
	  "vga=current"
	  "fbcon=nodefer"   # Defer framebuffer console to avoid flickering

	  # Disable legacy serial port probing to fix initrd delay
	  "8250.nr_uarts=0"
	]
  ];
  
  # Suppress console log messages (0 = only emergency messages)
  boot.consoleLogLevel = 0;
  
  # ───── Boot Performance Optimizations ─────
  
  # Enable parallel service startup
  systemd.services = {
	# Delay non-critical firmware updates to after boot
	fwupd.wantedBy = lib.mkForce [];
	fwupd-refresh.wantedBy = lib.mkForce [];
	
	# Note: powertop is disabled in power.nix, no need to configure it here
	
	# Explicitly disable orphaned nixos-upgrade service (leftover from old config)
	# This service is trying to access /home/pixel-peeper/wow which doesn't exist
	# and is blocking boot for ~79 seconds
	nixos-upgrade = {
	  enable = false;
	  wantedBy = lib.mkForce [];
	};
  };

}
