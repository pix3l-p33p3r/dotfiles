# Alucard — ThinkPad, Intel Gen12 Tiger Lake Iris Xe, single iGPU, Hyprland/Wayland
# Verification: docs/machines/alucard/HARDWARE-ACCELERATION.md
{ config, pkgs, lib, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Steam/Wine 32-bit support
    extraPackages = with pkgs; [
      intel-media-driver  # iHD — required for Gen12; i965 not needed on Tiger Lake
      libva-vdpau-driver
      libvdpau-va-gl
      intel-compute-runtime # OpenCL (NEO)
      level-zero
      vpl-gpu-rt           # Intel VPL (replaces deprecated intel-media-sdk)
    ];

    extraPackages32 = with pkgs.driversi686Linux; [
      intel-media-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  boot.kernelParams = [
    "i915.enable_guc=3"  # GuC submission + HuC firmware (Gen9+)
    "i915.enable_psr=1"  # Panel Self Refresh — disable if flicker appears
    "i915.enable_fbc=1"  # Framebuffer Compression
  ];

  boot.kernelModules = [
    "i915"
    "kvm-intel"
  ];

  # i915 and thinkpad_acpi share extraModprobeConfig; mkForce prevents conflicts
  boot.extraModprobeConfig = lib.mkForce ''
    options i915 enable_guc=3 enable_fbc=1 enable_psr=1
    options thinkpad_acpi experimental=1 fan_control=1
  '';

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME    = "iHD";
    VDPAU_DRIVER         = "va_gl";
    VK_ICD_FILENAMES     = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
    MOZ_DISABLE_RDD_SANDBOX = "1"; # Firefox VA-API in RDD process
    LIBVA_MESSAGING_LEVEL = "1";   # 0=off 1=errors 2=verbose
    VDPAU_LOG            = "0";
  };

  environment.systemPackages = with pkgs; [
    libva-utils           # vainfo
    vdpauinfo
    vulkan-tools          # vulkaninfo, vkcube
    vulkan-loader
    vulkan-headers
    vulkan-validation-layers
    intel-gpu-tools       # intel_gpu_top
    clinfo
    mesa-demos            # glxinfo, glxgears
  ];

  users.users.pixel-peeper.extraGroups = [ "video" "render" ];

  systemd.tmpfiles.rules = [
    "a /dev/dri/card* - - - - u:pixel-peeper:rw-"
    "a /dev/dri/renderD* - - - - u:pixel-peeper:rw-"
  ];
}
