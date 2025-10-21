{ ... }:

{
  # ============================================================================
  # Catppuccin Mocha Theme Configuration
  # ============================================================================
  # This file configures Catppuccin Mocha theme for all compatible applications
  # in your system, providing a consistent and beautiful dark theme experience.

  # Global Catppuccin configuration
  catppuccin.flavor = "mocha";

  # ============================================================================
  # CLI & System Tools
  # ============================================================================
  
  # System monitoring & resource tools
  catppuccin.btop.enable = true;
  catppuccin.btop.flavor = "mocha";

  # Command-line tools
  catppuccin.bat.enable = true;
  catppuccin.bat.flavor = "mocha";

  catppuccin.eza.enable = true;
  catppuccin.eza.flavor = "mocha";

  catppuccin.fzf.enable = true;
  catppuccin.fzf.flavor = "mocha";

  # catppuccin.fd.enable = true;  # Not supported in current catppuccin module
  # catppuccin.fd.flavor = "mocha";

  # catppuccin.ripgrep.enable = true;
  # catppuccin.ripgrep.flavor = "mocha";

  # ============================================================================
  # Terminal & Shell
  # ============================================================================
  
  # Terminal multiplexer
  catppuccin.tmux.enable = true;
  catppuccin.tmux.flavor = "mocha";

  # Terminal emulator (already configured via manual theme files)
  # catppuccin.kitty.enable = true;  # Disabled - using manual config
  
  # File manager (TUI)
  catppuccin.yazi.enable = true;
  catppuccin.yazi.flavor = "mocha";

  # ============================================================================
  # Development Tools
  # ============================================================================
  
  # Git tools
  catppuccin.lazygit.enable = true;
  catppuccin.lazygit.flavor = "mocha";

  catppuccin.gitui.enable = true;
  catppuccin.gitui.flavor = "mocha";

  # ============================================================================
  # Media & Documents
  # ============================================================================
  
  # Document viewer
  catppuccin.zathura.enable = true;
  catppuccin.zathura.flavor = "mocha";

  # Media players
  catppuccin.mpv.enable = true;
  catppuccin.mpv.flavor = "mocha";

  catppuccin.imv.enable = true;
  catppuccin.imv.flavor = "mocha";

  # ============================================================================
  # Wayland & Desktop Environment
  # ============================================================================
  
  # Desktop widgets and panel
  # catppuccin.waybar.enable = true;
  # catppuccin.waybar.flavor = "mocha";

  # Window manager (if using catppuccin integration)
  # catppuccin.hyprland.enable = true;  # Disabled - using custom config
  
  # Screen lock (if using catppuccin integration)
  # catppuccin.hyprlock.enable = true;  # Disabled - using custom config

  # Application launcher
  catppuccin.wofi.enable = true;
  catppuccin.wofi.flavor = "mocha";

  # ============================================================================
  # Audio & Media
  # ============================================================================
  
  # Audio visualizer
  catppuccin.cava.enable = true;
  catppuccin.cava.flavor = "mocha";
}
