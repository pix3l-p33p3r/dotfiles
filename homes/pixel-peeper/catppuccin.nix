{ ... }:

{
  # ============================================================================
  # Catppuccin Mocha Theme Configuration
  # ============================================================================
  # This file configures Catppuccin Mocha theme for all compatible applications
  # in your system, providing a consistent and beautiful dark theme experience.

  # Global Catppuccin configuration
  catppuccin.flavor = "mocha";
  catppuccin.accent = "lavender";


  # ============================================================================
  # CLI & System Tools
  # ============================================================================
  
  # System monitoring & resource tools
  catppuccin.btop.enable = true;

  # Command-line tools
  catppuccin.bat.enable = true;

  catppuccin.eza.enable = true;

  catppuccin.fzf.enable = true;

  # ============================================================================
  # Terminal & Shell
  # ============================================================================
  
  # Terminal multiplexer
  catppuccin.tmux.enable = true;

  # Terminal emulator
  catppuccin.kitty.enable = true;
  catppuccin.zsh-syntax-highlighting.enable = true;
  catppuccin.atuin.enable = true;
  
  # File manager (TUI)
  catppuccin.yazi.enable = true;

  # ============================================================================
  # Development Tools
  # ============================================================================
  
  # Git tools
  catppuccin.lazygit.enable = true;

  catppuccin.gitui.enable = true;

  # ============================================================================
  # Media & Documents
  # ============================================================================
  
  # Document viewer
  catppuccin.zathura.enable = true;

  # Media players
  catppuccin.mpv.enable = true;

  catppuccin.imv.enable = true;

  # ============================================================================
  # Wayland & Desktop Environment
  # ============================================================================

  # Application launcher
  catppuccin.rofi.enable = true;

  # Hyprland components
  catppuccin.hyprland.enable = true;
  catppuccin.hyprlock.enable = true;

  # Qt theming via Kvantum
  catppuccin.kvantum.enable = true;

  # ============================================================================
  # Audio & Media
  # ============================================================================
  
  
  # Audio visualizer
  catppuccin.cava.enable = true;

  # ============================================================================
  # Browsers & Web Applications
  # ============================================================================

  # Discord client (vesktop)
  catppuccin.vesktop.enable = true;

  # Browsers
  catppuccin.qutebrowser.enable = true;
  catppuccin.librewolf.enable = true;

  # Kubernetes TUI
  catppuccin.k9s.enable = true;

  # Binary cache (optional)
  catppuccin.cache.enable = true;

  # Cursor theme
  catppuccin.cursors.enable = true;

  # Catppuccin TTY theme
  # catppuccin.tty.enable = true;
}
