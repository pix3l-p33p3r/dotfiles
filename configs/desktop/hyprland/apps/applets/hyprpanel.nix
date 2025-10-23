{ lib, pkgs, ... }:
{
  # Hyprpanel configuration
  xdg.configFile."hyprpanel/hyprpanel.conf".text = ''
    # Hyprpanel Configuration
    # A modern status bar for Hyprland

    # General settings
    general {
        # Panel position: top, bottom, left, right
        position = top
        
        # Panel height
        height = 40
        
        # Panel width (for left/right position)
        width = 300
        
        # Panel margin from screen edge
        margin = 10
        
        # Panel padding
        padding = 8
        
        # Background color
        background = rgba(30, 30, 46, 0.8)
        
        # Border radius
        border_radius = 8
        
        # Border width
        border_width = 1
        
        # Border color
        border_color = rgba(205, 214, 244, 0.1)
        
        # Font family
        font_family = "Noto Sans"
        
        # Font size
        font_size = 12
        
        # Text color
        text_color = #cdd6f4
        
        # Icon font
        icon_font = "Font Awesome 6 Free"
    }

    # Workspace module
    workspace {
        # Show workspace numbers
        show_numbers = true
        
        # Show workspace names
        show_names = true
        
        # Active workspace color
        active_color = #a6e3a1
        
        # Inactive workspace color
        inactive_color = #6c7086
        
        # Urgent workspace color
        urgent_color = #f38ba8
        
        # Workspace spacing
        spacing = 8
    }

    # Clock module
    clock {
        # Time format
        format = "%H:%M:%S"
        
        # Date format
        date_format = "%a %d %b"
        
        # Show date
        show_date = true
        
        # Clock color
        color = #cdd6f4
    }

    # System info module
    system {
        # Show CPU usage
        show_cpu = true
        
        # Show memory usage
        show_memory = true
        
        # Show temperature
        show_temperature = true
        
        # Update interval (seconds)
        update_interval = 1
        
        # System info color
        color = #cdd6f4
    }

    # Network module
    network {
        # Network interface
        interface = wlp0s20f3
        
        # Show download speed
        show_download = true
        
        # Show upload speed
        show_upload = true
        
        # Network color
        color = #cdd6f4
        
        # Connected color
        connected_color = #a6e3a1
        
        # Disconnected color
        disconnected_color = #f38ba8
    }

    # Audio module
    audio {
        # Show volume
        show_volume = true
        
        # Show mute status
        show_mute = true
        
        # Audio color
        color = #cdd6f4
        
        # Muted color
        muted_color = #f38ba8
    }

    # Battery module
    battery {
        # Show battery percentage
        show_percentage = true
        
        # Show battery status
        show_status = true
        
        # Battery color
        color = #cdd6f4
        
        # Low battery color
        low_color = #f38ba8
        
        # Charging color
        charging_color = #a6e3a1
    }

    # Brightness module
    brightness {
        # Show brightness percentage
        show_percentage = true
        
        # Brightness color
        color = #cdd6f4
    }

    # Tray module
    tray {
        # Show system tray
        show_tray = true
        
        # Tray icon size
        icon_size = 16
        
        # Tray spacing
        spacing = 4
    }

    # Notification module
    notification {
        # Show notification count
        show_count = true
        
        # Notification color
        color = #cdd6f4
        
        # Unread color
        unread_color = #f38ba8
    }

    # Power profile module
    power_profile {
        # Show power profile
        show_profile = true
        
        # Power profile color
        color = #cdd6f4
        
        # Performance color
        performance_color = #f38ba8
        
        # Balanced color
        balanced_color = #fab387
        
        # Power saver color
        power_saver_color = #a6e3a1
    }
  '';

  # Hyprpanel service
  systemd.user.services.hyprpanel = {
    Unit = {
      Description = "Hyprpanel status bar";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.hyprpanel}/bin/hyprpanel";
      Restart = "on-failure";
      RestartSec = 1;
      Environment = [
        "WAYLAND_DISPLAY=%i"
        "XDG_CURRENT_DESKTOP=Hyprland"
      ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
