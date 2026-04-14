{ config, pkgs, lib, ... }:
let
  # nixpkgs hard-codes cat-mocha-blue; patch the installPhase at build time for lavender.
  catppuccinPapirusFoldersLavender = pkgs.catppuccin-papirus-folders.overrideAttrs (old: {
    installPhase = builtins.replaceStrings [ "cat-mocha-blue" ] [ "cat-mocha-lavender" ] old.installPhase;
  });
in
{
	# Cursor size/source of truth (Catppuccin provides theme, HM sets size)
	home.pointerCursor = {
		size = 24;
	};

	gtk = {
		enable = true;
		iconTheme = {
			package = catppuccinPapirusFoldersLavender;
			name = "Papirus-Dark";
		};

		# HM ≥26.05 defaults gtk4 theme separately; keep GTK3/GTK4 aligned with Stylix until stateVersion migrates.
		gtk4.theme = config.gtk.theme;

		gtk3.extraConfig = {
			gtk-application-prefer-dark-theme = true;
		};

		gtk4.extraConfig = {
			gtk-application-prefer-dark-theme = true;
		};
	};


	stylix = {

		enable = true;

		# Own hyprpaper preload/wallpaper in services.hyprpaper; Stylix would merge wallpaper entries and fight our flake image.
		targets.hyprpaper.enable = false;

		# Own full config in hypr/hyprlock.conf (hyprlock ignores ~/.config/hyprlock/). Stylix would merge programs.hyprlock.settings.
		targets.hyprlock.enable = false;

		targets.zen-browser.profileNames = [ "default" ];


		fonts.monospace = {
			name = "JetBrainsMono Nerd Font";
			package = pkgs.nerd-fonts.jetbrains-mono;
		};

		fonts.sansSerif = {
			name = "JetBrainsMono Nerd Font";
			package = pkgs.nerd-fonts.jetbrains-mono;
		};

		fonts.serif = {
			name = "JetBrainsMono Nerd Font";
			package = pkgs.nerd-fonts.jetbrains-mono;
		};

		fonts.sizes.applications = 11;

		polarity = "dark";

		base16Scheme = {
			base00 = "1e1e2e"; # base
			base01 = "181825"; # mantle
			base02 = "313244"; # surface0
			base03 = "45475a"; # surface1
			base04 = "585b70"; # surface2
			base05 = "cdd6f4"; # text
			base06 = "f5e0dc"; # rosewater
			base07 = "b4befe"; # lavender
			base08 = "f38ba8"; # red
			base09 = "fab387"; # peach
			base0A = "f9e2af"; # yellow
			base0B = "a6e3a1"; # green
			base0C = "94e2d5"; # teal
			base0D = "89b4fa"; # blue
			base0E = "cba6f7"; # mauve
			base0F = "f2cdcd"; # flamingo
		};

		#targets.firefox.profileNames = [ "orbit" ];
	};
}
