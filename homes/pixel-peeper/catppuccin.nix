{ ... }:

{
  catppuccin.flavor = "mocha";
  catppuccin.accent = "lavender";

  catppuccin.btop.enable = true;
  catppuccin.bat.enable = true;
  catppuccin.eza.enable = true;
  catppuccin.fzf.enable = true;

  catppuccin.tmux.enable = true;
  catppuccin.kitty.enable = true;
  catppuccin.zsh-syntax-highlighting.enable = true;
  catppuccin.atuin.enable = true;
  # catppuccin.yazi.enable = true;  # conflicts with programs.yazi in yazi.nix

  catppuccin.lazygit.enable = true;
  # catppuccin.gitui.enable = true;

  catppuccin.zathura.enable = true;
  catppuccin.mpv.enable = true;
  catppuccin.imv.enable = true;

  catppuccin.rofi.enable = true;
  # catppuccin.hyprland.enable = true;
  # catppuccin.hyprlock.enable = true;

  catppuccin.kvantum.enable = true;
  catppuccin.cava.enable = true;

  catppuccin.vesktop.enable = true;
  catppuccin.qutebrowser.enable = true;
  catppuccin.librewolf.enable = true;

  catppuccin.k9s.enable = true;

  # cache is configured system-wide in machines/alucard/system.nix;
  # enabling here writes extra-trusted-public-keys to ~/.config/nix/nix.conf
  # which breaks signature verification in Nix 2.31.x.
  # catppuccin.cache.enable = true;

  catppuccin.cursors.enable = true;
  # catppuccin.tty.enable = true;
}
