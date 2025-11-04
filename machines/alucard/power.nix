{ config, pkgs, lib, ... }:

{
  # ───── Power Management Services ─────
  
  # UPower: provides battery information and notification services
  # Required for poweralertd to work properly
  services.upower.enable = true;

  # ───── Suspend, Hibernation & Power Saving ─────
  
  # Enable suspend/hibernate support
  powerManagement.enable = true;

  # Configure power management policies
  # Disabled to improve boot time - TLP already handles power management effectively
  powerManagement.powertop.enable = false;  # Intel CPU power management tool
  
  # Systemd logind power management settings
  services.logind = {
    # Additional power key handling settings
    settings = {
      Login = {
        # Handle lid switch (close) actions
        HandleLidSwitch = "suspend";
        HandleLidSwitchDocked = "ignore";
        
        # Handle power button action
        HandlePowerKey = "suspend";
        HandlePowerKeyLongPress = "poweroff";
        
        # Additional power key handling
        SuspendKey = "suspend";
        HibernateKey = "hibernate";
      };
    };
  };

  # ───── CPU Governor ─────
  # Set default CPU frequency scaling governor
  # Options: ondemand, conservative, performance, powersave, schedutil
  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  # ───── TLP Power Management ─────
  # Advanced power management for laptops
  services.tlp = {
    enable = true;
    settings = {
      # CPU settings
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      
      # CPU frequency limits
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MAX_PERF_ON_BAT = 50;  # favor battery life slightly more
      CPU_MIN_PERF_ON_BAT = 20;
      
      # CPU boosting
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      
      # Turbo mode
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;
      
      # GPU
      INTEL_GPU_MIN_FREQ_ON_AC = 350;
      INTEL_GPU_MIN_FREQ_ON_BAT = 150;
      INTEL_GPU_MAX_FREQ_ON_AC = 1200;
      INTEL_GPU_MAX_FREQ_ON_BAT = 600;
      INTEL_GPU_BOOST_FREQ_ON_AC = 1300;
      INTEL_GPU_BOOST_FREQ_ON_BAT = 650;
      
      # Keyboard backlight
      KEYBOARD_BRIGHTNESS_STEPS = "0 50 100";
      KEYBOARD_BRIGHTNESS_ON_AC = 100;
      KEYBOARD_BRIGHTNESS_ON_BAT = 50;
      
      # WiFi power saving
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      # PCIe runtime power management
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      # USB autosuspend (blacklist devices if any issues)
      USB_AUTOSUSPEND = 1;

      # Audio power saving
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";

      # PCIe ASPM policy
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";
      
      # Battery charge thresholds (20% start, 80% stop)
      # Helps extend battery lifespan by avoiding full charge cycles
      START_CHARGE_THRESH_BAT0 = 20;  # Start charging when battery drops below 20%
      STOP_CHARGE_THRESH_BAT0 = 80;   # Stop charging when battery reaches 80%
    };
  };

  # ───── Power Daemon Conflicts ─────
  # TLP and power-profiles-daemon conflict - using TLP exclusively
  services.thermald.enable = true;   # Complement TLP on Intel platforms
  services.power-profiles-daemon.enable = false;  # Disabled to avoid conflict with TLP

  # ───── System76 Scheduler (CFS profiles) ─────
  # Improves interactivity under load
  services.system76-scheduler = {
    enable = true;
    settings.cfsProfiles.enable = true;
  };
}