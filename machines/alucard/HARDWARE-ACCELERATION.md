# Intel Hardware Acceleration Guide

Complete hardware acceleration setup for Intel integrated graphics on Alucard (ThinkPad).

## 🚀 What's Enabled

### Video Decode/Encode (VA-API)
- **H.264** (AVC) - decode & encode
- **H.265** (HEVC) - decode & encode  
- **VP8** - decode
- **VP9** - decode & encode
- **AV1** - decode (on newer Intel GPUs)

### Graphics APIs
- **Vulkan** - Modern graphics API (gaming, compute)
- **OpenGL** - Legacy graphics API
- **OpenCL** - GPU compute workloads

### Drivers
- **iHD** (intel-media-driver) - Modern VA-API driver for Gen8+
- **Level Zero** - oneAPI compute runtime
- **Intel Compute Runtime** - OpenCL support

## 🔍 Verification Commands

After rebuilding, verify your setup:

```bash
# VA-API (Video Acceleration)
vainfo
# Expected: "iHD driver" with H264/HEVC decode/encode

# VDPAU (via VA-API)
vdpauinfo
# Expected: VDPAU capabilities through VA-API backend

# Vulkan
vulkaninfo --summary
# Expected: Intel Vulkan driver detected

# OpenCL
clinfo
# Expected: Intel OpenCL platform

# GPU monitoring
intel_gpu_top
# Expected: Real-time GPU stats (Video/Render/Blitter engines)

# OpenGL
glxinfo | grep "OpenGL renderer"
# Expected: Mesa Intel graphics info
```

## 🎬 Application Configuration

### MPV (Already Configured)
Hardware acceleration is enabled by default in `configs/media/mpv.nix`:
```bash
mpv --hwdec=auto video.mp4
# Monitor with: intel_gpu_top (Video engine should show usage)
```

### Firefox
Already configured via environment variables:
- `MOZ_DISABLE_RDD_SANDBOX=1` - Enable VA-API
- `MOZ_X11_EGL=1` - Use EGL for XWayland

Verify in Firefox:
1. Visit `about:support`
2. Search for "Graphics"
3. Look for "WEBRENDER" and "VA-API"

### Chromium/Chrome
Add to launch flags:
```bash
chromium --enable-features=VaapiVideoDecoder,VaapiVideoEncoder \
         --use-gl=egl \
         --enable-zero-copy
```

### OBS Studio
Enable in Settings → Advanced:
- VAAPI encoding for H.264/HEVC

### FFmpeg
Use hardware acceleration in commands:
```bash
# Decode with VA-API
ffmpeg -hwaccel vaapi -i input.mp4 output.mp4

# Encode with VA-API (H.264)
ffmpeg -i input.mp4 -c:v h264_vaapi -b:v 2M output.mp4

# Encode with Quick Sync (QSV)
ffmpeg -i input.mp4 -c:v h264_qsv -preset veryslow output.mp4
```

### VLC
1. Tools → Preferences → Input/Codecs
2. Hardware-accelerated decoding: **VA-API video decoder**

## ⚡ Performance Impact

**Without Hardware Acceleration:**
- 4K HEVC: ~60-80% CPU usage
- 1080p AVC: ~30-40% CPU usage
- Battery drain: High
- Heat: Significant

**With Hardware Acceleration:**
- 4K HEVC: ~5-10% CPU usage (handled by GPU)
- 1080p AVC: ~2-5% CPU usage
- Battery drain: Minimal
- Heat: Minimal

## 🔧 Troubleshooting

### VA-API not working?

Check driver loaded:
```bash
echo $LIBVA_DRIVER_NAME  # Should be "iHD"
vainfo
```

### Permission denied errors?

Verify user groups:
```bash
groups pixel-peeper  # Should include "video" and "render"
ls -l /dev/dri/       # Should show card0 and renderD128
```

### Firefox not using hardware acceleration?

1. Check `about:config`:
   - `media.ffmpeg.vaapi.enabled` = true
   - `media.ffvpx.enabled` = false
   - `media.navigator.mediadatadecoder_vpx_enabled` = true

2. Check `about:support` for VA-API in "Media" section

### Intel GPU not detected?

```bash
lspci | grep VGA
# Should show Intel graphics

lsmod | grep i915
# Should show i915 module loaded
```

## 📊 Monitoring GPU Usage

Real-time monitoring:
```bash
# Intel GPU top (best option)
intel_gpu_top

# Alternative: radeontop (cross-GPU support)
radeontop

# nvtop (supports Intel)
nvtop --gpu intel
```

Expected engines:
- **Render/3D** - Gaming, desktop compositing
- **Video** - Hardware video decode/encode
- **VideoEnhance** - Video post-processing
- **Blitter** - Memory copy operations

## 🎮 Gaming Performance

Hardware acceleration also benefits:
- **Wine/Proton** - DirectX translation
- **Steam** - Vulkan/OpenGL games
- **Native games** - Better performance

## 🔋 Power Savings

Hardware acceleration significantly reduces:
- CPU usage (offloaded to GPU)
- Power consumption (GPU more efficient)
- Heat generation (lower overall load)
- Fan noise (cooler system)

Expected battery life improvement: **30-50%** during video playback

## 🛠️ Advanced Configuration

### Force specific VA-API driver

In `hardware-acceleration.nix`, change:
```nix
LIBVA_DRIVER_NAME = "iHD";   # Modern (default)
# or
LIBVA_DRIVER_NAME = "i965";  # Legacy (pre-Broadwell)
```

### Enable GuC/HuC debug logging

```bash
sudo dmesg | grep -i "guc\|huc"
# Should show GuC/HuC firmware loaded
```

### Check supported codecs

```bash
vainfo | grep -A 20 "VAEntrypointVLD\|VAEntrypointEncSlice"
```

## 📝 Configuration Files

Hardware acceleration is configured in:
- **System**: `machines/alucard/hardware-acceleration.nix`
- **MPV**: `configs/media/mpv.nix`
- **Environment**: Automatic via NixOS

## 🆘 Need Help?

Check Intel GPU generation:
```bash
lspci -v | grep -A 10 VGA
```

Supported generations:
- **Gen8+** (Broadwell and newer) - Full support
- **Gen7** (Haswell) - Limited support
- **Gen6 and older** - Use i965 driver

---

**Status**: ✅ Fully Configured  
**Driver**: iHD (intel-media-driver)  
**VA-API**: Enabled  
**Vulkan**: Enabled  
**OpenCL**: Enabled

