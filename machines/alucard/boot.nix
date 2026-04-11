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

	# Show boot menu for 1 second — allows selecting previous NixOS generations
	boot.loader.timeout = 1;

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
	# Combines assets from nixos-catppuccin-plymouth with dialog assets from the default
	# spinner theme so the two-step module can render the LUKS password prompt
	nixpkgs.overlays = [
		(self: super: {
			catppuccin_plymouth_password = super.stdenv.mkDerivation rec {
				pname = "catppuccin-plymouth-password";
				version = "0.0.3";
				src = "${inputs.nixos-catppuccin-plymouth}/src/theme";

				dontUnpack = true;
				dontBuild = true;

				installPhase = let
					themeDir = "$out/share/plymouth/themes/catppuccin-password";
					spinnerDir = "${super.plymouth}/share/plymouth/themes/spinner";
				in ''
					mkdir -p ${themeDir}

					# Catppuccin ships nixos-*.png for the script module; two-step uses
					# throbber-NNNN.png for the looping boot animation (same pattern as spinner).
					i=1
					for srcimg in $(ls ${src}/nixos-*.png | sort -V); do
						cp "$srcimg" "${themeDir}/$(printf 'throbber-%04d.png' "$i")"
						i=$((i + 1))
					done

					# Password dialog assets required by the two-step module
					for asset in bullet.png entry.png lock.png capslock.png keyboard.png keymap-render.png; do
						if [ -f "${spinnerDir}/$asset" ]; then
							cp "${spinnerDir}/$asset" ${themeDir}/
						fi
					done

					cat > ${themeDir}/catppuccin-password.plymouth <<THEMEEOF
[Plymouth Theme]
Name=catppuccin-password
Description=Catppuccin Mocha with visible LUKS password entry
ModuleName=two-step

[two-step]
Font=Noto Sans 13
TitleFont=Noto Sans Bold 34
ImageDir=${themeDir}
DialogHorizontalAlignment=.5
DialogVerticalAlignment=.5
TitleHorizontalAlignment=.5
TitleVerticalAlignment=.4
HorizontalAlignment=.5
VerticalAlignment=.5
WatermarkHorizontalAlignment=.5
WatermarkVerticalAlignment=.92
Transition=fade
TransitionDuration=0.25
BackgroundStartColor=0x1e1e2e
BackgroundEndColor=0x11111b
ProgressBarBackgroundColor=0x313244
ProgressBarForegroundColor=0xb4befe
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
DeviceScale=1
		'';
	};

	# Disable the catppuccin.plymouth module to avoid conflicts
	catppuccin.plymouth.enable = lib.mkForce false;
	
	# Modern systemd-based initrd with Plymouth support
	boot.initrd = {
	systemd.enable = true;  # Required for Plymouth + systemd-ask-password in initrd
	verbose = false;

	# Max zstd compression — smaller initrd, faster decompression at boot
	# -19 = max level, -T0 = use all CPU threads (only affects rebuild time)
	compressor = "zstd";
	compressorArgs = [ "-19" "-T0" ];

	# TPM2 support: tpm_tis is the driver for STM0125 (confirmed via lsmod)
	# i915 for Plymouth early-KMS
	kernelModules = [ "i915" "tpm_tis" ];

	# Only ext4 (root/data) and vfat (/boot ESP) are used — btrfs removed
	supportedFilesystems = [ "ext4" "vfat" ];

	# Enable tpm2-tss in initrd so systemd-cryptsetup can use the TPM2 token
	systemd.tpm2.enable = true;
	};

	boot.initrd.luks.devices.${luksDevice} = {
	allowDiscards = true;
	bypassWorkqueues = true;
	preLVM = true;
	# tpm2-device=auto: unlock via TPM2 when Secure Boot chain is valid (PCRs 0+7)
	# Falls back to passphrase if TPM2 seal fails (e.g. Secure Boot disabled)
	crypttabExtraOpts = [
		"tpm2-device=auto"
		"tpm2-pcrs=0+7"
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
		# Omit plymouth.use-simpledrm: conflicts with i915 early-KMS on some Intel laptops
		"loglevel=3"      # Show only errors (3 = err)

		# Systemd boot messages
		"systemd.show_status=false"      # Hide systemd status
		"rd.systemd.show_status=false"   # Hide systemd status in initrd

		# Udev messages
		"rd.udev.log_level=3"  # Reduce udev verbosity in initrd
		"udev.log_priority=3"  # Reduce udev messages

		# Framebuffer / DRM transition
		# Force EFI framebuffer to native resolution so simpledrm and i915 agree
		"video=eDP-1:1920x1080@60"
		# Prevent i915 from doing a full mode-reset when it takes over from simpledrm;
		# without this Plymouth sees a blank screen during the simpledrm→i915 handoff
		"i915.fastboot=1"
		# PSR (Panel Self Refresh) triggers I2C bus arbitration failures on this
		# ThinkPad, causing the SYNA800E touchpad to lock up after 10-15 minutes.
		"i915.enable_psr=0"
		# Disable legacy serial port probing to fix initrd delay
		"8250.nr_uarts=0"

		# Disable kernel and hardware watchdog — not needed on a laptop
		"nowatchdog"
		"nmi_watchdog=0"

		# Give the i2c_designware controller more time to initialize so the
		# Synaptics touchpad (SYNA800E) doesn't time out during cold boot
		"i2c_designware.timeout_ms=1000"
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

	# Note: NetworkManager-wait-online is disabled in system.nix.
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
