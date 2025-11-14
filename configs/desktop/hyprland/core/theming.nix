{ pkgs, lib, ... }:
{
	# Cursor size/source of truth (Catppuccin provides theme, HM sets size)
	home.pointerCursor = {
		size = 24;
	};

	gtk = {
		enable = true;
		iconTheme = {
			package = pkgs.catppuccin-papirus-folders;
			name = "Papirus-Dark";
		};

		gtk3.extraConfig = {
			gtk-application-prefer-dark-theme = true;
		};

		gtk4.extraConfig = {
			gtk-application-prefer-dark-theme = true;
		};
	};

  # Ensure Papirus folder color matches Catppuccin Mocha Lavender (GTK module removed upstream)
  home.activation.setPapirusFolders = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v papirus-folders >/dev/null 2>&1; then
      papirus-folders -C cat-mocha-lavender --theme Papirus-Dark || true
    fi
  '';

	stylix = {

		enable = true;

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
			base0E = "b4befe"; # lavender
			base0F = "f2cdcd"; # flamingo
		};

		#targets.firefox.profileNames = [ "orbit" ];
	};
}
