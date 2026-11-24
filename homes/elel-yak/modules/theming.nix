{ pkgs, lib, ... }:
let
  catppuccinGtk = pkgs.catppuccin-gtk.override {
    accents = [ "lavender" ];
    variant = "mocha";
  };
  catppuccinCursors = pkgs.catppuccin-cursors.mochaLavender;
  # Match homes/pixel-peeper theming.nix: patch cat-mocha-blue -> cat-mocha-lavender.
  catppuccinPapirus = pkgs.catppuccin-papirus-folders.overrideAttrs (old: {
    installPhase = builtins.replaceStrings [ "cat-mocha-blue" ] [ "cat-mocha-lavender" ] old.installPhase;
  });
in
{
  home.packages = [
    catppuccinGtk
    catppuccinCursors
    catppuccinPapirus
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
  ];

  # GNOME Shell & Ubuntu GTK apps run OUTSIDE nix-user-chroot, so they cannot
  # follow /nix/store symlinks. Copy real assets onto /goinfre (visible on host
  # and keeps tiny 4.7G $HOME clean), then symlink ~/.themes, ~/.local/share/...
  home.activation.catppuccinGnomeTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ASSETS="/goinfre/elel-yak/theme-assets"
    [ -d "$ASSETS" ] && chmod -R u+w "$ASSETS" 2>/dev/null || true
    mkdir -p "$ASSETS/themes" "$ASSETS/icons" "$ASSETS/fonts" \
      "$HOME/.local/share/icons" "$HOME/.local/share/fonts" \
      "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"

    # 1. GTK3 / GTK4 / GNOME Shell theme (Catppuccin Mocha Lavender)
    rm -rf "$ASSETS/themes"/*
    cp -rL --no-preserve=mode "${catppuccinGtk}/share/themes/." "$ASSETS/themes/"
    if [ -d "$HOME/.themes" ] && [ ! -L "$HOME/.themes" ]; then
      rm -rf "$HOME/.themes"
    fi
    ln -sfn "$ASSETS/themes" "$HOME/.themes"

    THEME_NAME="$(basename "$(ls -d "$ASSETS/themes"/catppuccin-mocha-lavender* 2>/dev/null | head -n 1)")"
    if [ -n "$THEME_NAME" ] && [ -d "$ASSETS/themes/$THEME_NAME/gtk-4.0" ]; then
      ln -sfn "$ASSETS/themes/$THEME_NAME/gtk-4.0/assets" "$HOME/.config/gtk-4.0/assets"
      ln -sfn "$ASSETS/themes/$THEME_NAME/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
      ln -sfn "$ASSETS/themes/$THEME_NAME/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"
    fi

    # 2. Icons (Papirus + Papirus-Dark with Catppuccin Mocha Lavender folders) + Cursors
    # Preserve relative symlinks (-P) so Papirus stays ~90M instead of ~1.8G dereferenced.
    rm -rf "$ASSETS/icons/Papirus" "$ASSETS/icons/Papirus-Dark" "$ASSETS/icons"/catppuccin-*
    cp -rP --no-preserve=mode "${catppuccinPapirus}/share/icons/Papirus" "$ASSETS/icons/Papirus"
    cp -rP --no-preserve=mode "${catppuccinPapirus}/share/icons/Papirus-Dark" "$ASSETS/icons/Papirus-Dark"
    cp -rP --no-preserve=mode "${catppuccinCursors}/share/icons/." "$ASSETS/icons/"

    ln -sfn "$ASSETS/icons/Papirus" "$HOME/.local/share/icons/Papirus"
    ln -sfn "$ASSETS/icons/Papirus-Dark" "$HOME/.local/share/icons/Papirus-Dark"
    CURSOR_NAME="$(basename "$(ls -d "$ASSETS/icons"/catppuccin-mocha-lavender* 2>/dev/null | head -n 1)")"
    if [ -n "$CURSOR_NAME" ]; then
      ln -sfn "$ASSETS/icons/$CURSOR_NAME" "$HOME/.local/share/icons/$CURSOR_NAME"
    fi

    # 3. Nerd Fonts (JetBrainsMono + FiraCode) visible outside chroot
    rm -rf "$ASSETS/fonts"/*
    cp -rL --no-preserve=mode "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/." "$ASSETS/fonts/"
    cp -rL --no-preserve=mode "${pkgs.nerd-fonts.fira-code}/share/fonts/truetype/NerdFonts/." "$ASSETS/fonts/"
    ln -sfn "$ASSETS/fonts" "$HOME/.local/share/fonts/catppuccin-nerd"
    fc-cache -f "$HOME/.local/share/fonts" 2>/dev/null || true

    # 4. GTK3 settings.ini
    cat > "$HOME/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=$THEME_NAME
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=$CURSOR_NAME
gtk-cursor-theme-size=24
gtk-font-name=JetBrainsMono Nerd Font 11
EOF

    # 5. Live GNOME Shell & desktop interface settings
    if [ -x /usr/bin/gsettings ]; then
      /usr/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
      [ -n "$THEME_NAME" ] && /usr/bin/gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME" || true
      /usr/bin/gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' || true
      [ -n "$CURSOR_NAME" ] && /usr/bin/gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_NAME" || true
      /usr/bin/gsettings set org.gnome.desktop.interface cursor-size 24 || true
      /usr/bin/gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 11' || true
      /usr/bin/gsettings set org.gnome.desktop.interface document-font-name 'JetBrainsMono Nerd Font 11' || true
      /usr/bin/gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 11' || true
      /usr/bin/gsettings set org.gnome.desktop.wm.preferences titlebar-font 'JetBrainsMono Nerd Font Bold 11' || true
      if [ -n "$THEME_NAME" ] && [ -f "$ASSETS/themes/$THEME_NAME/gnome-shell/gnome-shell.css" ]; then
        /usr/bin/gsettings set org.gnome.shell.extensions.user-theme name "$THEME_NAME" || true
      fi
    fi

    # 6. Host-readable fontconfig override (outside nix-user-chroot)
    mkdir -p "$HOME/.config/fontconfig/conf.d"
    cat > "$HOME/.config/fontconfig/conf.d/99-catppuccin-fonts.conf" <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>JetBrainsMono Nerd Font</family>
      <family>FiraCode Nerd Font</family>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
</fontconfig>
EOF
    /usr/bin/fc-cache -f "$HOME/.local/share/fonts" 2>/dev/null || fc-cache -f "$HOME/.local/share/fonts" 2>/dev/null || true
  '';
}
