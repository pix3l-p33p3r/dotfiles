{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # |                    INTEL HARDWARE ACCELERATION                         |
  # ============================================================================
  # Comprehensive hardware acceleration for Intel integrated graphics
  # Optimized for media playback, encoding, and compute workloads
  
  # ───── Graphics Hardware ─────
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Enable 32-bit support for Steam/Wine compatibility
    
    extraPackages = with pkgs; [
      # Intel Media Driver (iHD) - Modern driver for Broadwell and newer
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      
      # Legacy VA-API driver (i965) for older Intel GPUs (optional fallback)
      # intel-vaapi-driver # LIBVA_DRIVER_NAME=i965
      
      # VA-API to VDPAU translation layer
      libva-vdpau-driver # For applications that only support VDPAU
      libvdpau-va-gl     # VDPAU driver with VA-API/OpenGL backend
      
      # Vulkan drivers
      intel-compute-runtime # Intel OpenCL runtime (NEO)
      level-zero           # oneAPI Level Zero loader
      
      # Additional codec support
      intel-media-sdk # Intel Media SDK (Quick Sync)
      vpl-gpu-rt      # Intel VPL GPU runtime (newer than Media SDK)
    ];
    
    extraPackages32 = with pkgs.driversi686Linux; [
      intel-media-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # ───── Intel GuC/HuC Firmware Loading ─────
  # Enable GuC (Graphics micro Controller) and HuC (HEVC/H265 micro Controller)
  # Required for modern Intel GPUs (Gen9+) for better performance and power
  boot.kernelParams = [
    # Enable GuC submission and HuC firmware loading
    "i915.enable_guc=3"  # 1=GuC submission, 2=HuC loading, 3=both
    
    # Enable Panel Self Refresh (PSR) for better battery life
    "i915.enable_psr=1"
    
    # Enable Framebuffer Compression (FBC) for power saving
    "i915.enable_fbc=1"
    
    # Faster GPU context switching
    "i915.fastboot=1"
  ];

  # ───── Kernel Modules ─────
  boot.kernelModules = [ 
    "i915"        # Intel GPU driver
    "kvm-intel"   # Intel virtualization
  ];

  # ───── System-wide Environment Variables ─────
  environment.sessionVariables = {
    # VA-API Configuration
    LIBVA_DRIVER_NAME = "iHD";  # Use modern Intel iHD driver (change to "i965" for older GPUs)
    
    # VDPAU Configuration (uses VA-API backend)
    VDPAU_DRIVER = "va_gl";
    
    # Vulkan ICD selection
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
    
    # Hardware video decode acceleration
    MOZ_DISABLE_RDD_SANDBOX = "1";  # Firefox hardware acceleration
    MOZ_X11_EGL = "1";               # Firefox EGL on X11/XWayland
    
    # General acceleration hints
    LIBVA_MESSAGING_LEVEL = "1";    # VA-API logging (0=off, 1=errors, 2=all)
    VDPAU_LOG = "0";                 # VDPAU logging (0=off, 1=errors, 3=all)
  };

  # ───── System Packages for Hardware Acceleration ─────
  environment.systemPackages = with pkgs; [
    # VA-API tools
    libva-utils      # vainfo - VA-API information and testing
    
    # VDPAU tools
    vdpauinfo        # VDPAU capability information
    
    # Vulkan tools
    vulkan-tools     # vulkaninfo, vkcube
    vulkan-loader
    vulkan-headers
    vulkan-validation-layers
    
    # Intel GPU tools
    intel-gpu-tools  # intel_gpu_top, intel_gpu_time, etc.
    clinfo           # OpenCL information
    
    # Media benchmarking
    mesa-demos       # glxinfo, glxgears
  ];

  # ───── OpenCL Support ─────
  # Enable Intel OpenCL runtime for compute workloads
  hardware.opengl.extraPackages = with pkgs; [
    intel-compute-runtime
    intel-ocl
  ];

  # ───── User Groups for Hardware Access ─────
  users.users.pixel-peeper.extraGroups = [
    "video"   # Video hardware access
    "render"  # GPU rendering access (required for some applications)
  ];

  # ───── Systemd Tmpfiles for Device Permissions ─────
  # Ensure proper permissions on GPU devices
  systemd.tmpfiles.rules = [
    "a /dev/dri/card* - - - - u:pixel-peeper:rw-"
    "a /dev/dri/renderD* - - - - u:pixel-peeper:rw-"
  ];

  # ───── Additional Optimizations ─────
  
  # Enable RC6 power saving (should be on by default, but explicit is good)
  boot.extraModprobeConfig = ''
    options i915 enable_guc=3 enable_fbc=1 enable_psr=1 fastboot=1
  '';

  # ───── Verification Commands ─────
  # After rebuilding, verify hardware acceleration with:
  #
  # VA-API: vainfo
  # Expected output: "iHD driver" with H264/HEVC decode/encode
  #
  # VDPAU: vdpauinfo
  # Expected output: VDPAU capabilities via VA-API
  #
  # Vulkan: vulkaninfo --summary
  # Expected output: Intel Vulkan driver with device name
  #
  # OpenCL: clinfo
  # Expected output: Intel OpenCL platforms
  #
  # Intel GPU: intel_gpu_top
  # Expected output: Real-time GPU utilization monitoring
  #
  # Quick test: mpv --hwdec=auto --vo=gpu video.mp4
  # Check with: intel_gpu_top (should show Video usage)
}

