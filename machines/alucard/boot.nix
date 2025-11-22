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
	
	# Custom Plymouth theme with password entry support using two-step module
	# Combines assets from nixos-catppuccin-plymouth with two-step module for visible password field
	nixpkgs.overlays = [
		(self: super: {
			catppuccin_plymouth_password = super.stdenv.mkDerivation rec {
				pname = "catppuccin-plymouth-password";
				version = "0.0.1";
				src = "${inputs.nixos-catppuccin-plymouth}/src/theme";

				buildInputs = [ super.git ];

				unpackPhase = ''
				'';

				configurePhase = ''
					mkdir -p $out/share/plymouth/themes/catppuccin-password
				'';

				buildPhase = ''
				'';

				installPhase = ''
					# Copy all PNG assets from the base theme
					cp -r ${src}/*png $out/share/plymouth/themes/catppuccin-password/ 2>/dev/null || true
					
					# Create .plymouth config file using two-step module (has built-in password entry)
					cat > $out/share/plymouth/themes/catppuccin-password/catppuccin-password.plymouth <<THEMEEOF
[Plymouth Theme]
Name=catppuccin-password
Description=Catppuccin Mocha with visible LUKS password entry
ModuleName=two-step

[two-step]
# Font configuration
Font=Noto Sans 13
TitleFont=Noto Sans Bold 34

# Image directory
ImageDir=$out/share/plymouth/themes/catppuccin-password

# Dialog positioning (password entry box) - centered
DialogHorizontalAlignment=.5
DialogVerticalAlignment=.5

# Title positioning (above password box)
TitleHorizontalAlignment=.5
TitleVerticalAlignment=.4

# Animation/throbber positioning (below password box)
HorizontalAlignment=.5
VerticalAlignment=.6

# Watermark positioning (optional, bottom of screen)
WatermarkHorizontalAlignment=.5
WatermarkVerticalAlignment=.92

# Visual effects
Transition=fade
TransitionDuration=0.25

# Colors (Catppuccin Mocha)
BackgroundStartColor=0x1e1e2e
BackgroundEndColor=0x11111b
ProgressBarBackgroundColor=0x313244
ProgressBarForegroundColor=0xb4befe

# Text configuration
MessageBelowAnimation=true
Title=The Bird of Hermes is my name
SubTitle=eating my own wings to make me tame

[boot-up]
UseEndAnimation=false

[shutdown]
UseEndAnimation=false

[reboot]
UseEndAnimation=false

[updates]
UseProgressBar=true
ProgressBarShowPercentComplete=true
Title=Applying updates...
SubTitle=Keep the machine powered
THEMEEOF
					
					# Make files executable
					chmod +x $out/share/plymouth/themes/catppuccin-password/catppuccin-password.plymouth
				'';
			};
		})
	];

	boot.plymouth = {
		enable = true;
		themePackages = [ pkgs.catppuccin_plymouth_password ];
		theme = "catppuccin-password";
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
