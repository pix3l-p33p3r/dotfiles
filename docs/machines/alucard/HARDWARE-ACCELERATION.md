# Intel Hardware Acceleration

Complete hardware acceleration setup for Intel integrated graphics on Alucard (ThinkPad).

## What's Enabled

**Video (VA-API):** H.264/HEVC decode+encode, VP8/VP9 decode+encode, AV1 decode (newer GPUs)  
**Graphics APIs:** Vulkan, OpenGL, OpenCL  
**Drivers:** iHD (intel-media-driver), Level Zero, Intel Compute Runtime

**Configuration:** `machines/alucard/hardware-acceleration.nix`

## Verification

```bash
vainfo              # Should show "iHD driver" with H264/HEVC
vulkaninfo --summary # Intel Vulkan driver
clinfo              # Intel OpenCL platform
intel_gpu_top       # Real-time GPU stats
```

## Application Setup

**MPV:** Already configured in `configs/media/mpv.nix` with `--hwdec=auto`

**Firefox:** VA-API enabled via env vars, native Wayland. Verify: `about:support` → Graphics → VA-API

**Chromium:** Launch with `--enable-features=VaapiVideoDecoder,VaapiVideoEncoder --use-gl=egl --enable-zero-copy`

**FFmpeg:**
```bash
ffmpeg -hwaccel vaapi -i input.mp4 output.mp4           # Decode
ffmpeg -i input.mp4 -c:v h264_vaapi -b:v 2M output.mp4  # Encode
ffmpeg -i input.mp4 -c:v h264_qsv -preset veryslow output.mp4  # QSV
```

**OBS/VLC:** Enable VAAPI encoding/decoding in settings

## Performance

**Without HW accel:** 4K HEVC ~60-80% CPU, high battery drain  
**With HW accel:** 4K HEVC ~5-10% CPU (GPU handles it), minimal battery drain

Expected battery improvement: **30-50%** during video playback.

## Troubleshooting

**VA-API not working:**
```bash
echo $LIBVA_DRIVER_NAME  # Should be "iHD"
groups $USER             # Should include "video" and "render"
ls -l /dev/dri/          # Should show card0 and renderD128
```

**Firefox not using HW accel:**
- Check `about:config`: `media.ffmpeg.vaapi.enabled = true`
- Verify in `about:support` → Media section

**GPU not detected:**
```bash
lspci | grep VGA        # Should show Intel graphics
lsmod | grep i915       # Should show i915 module loaded
```

## Monitoring

```bash
intel_gpu_top          # Best option - real-time stats
nvtop --gpu intel      # Alternative
```

Engines: Render/3D, Video (decode/encode), VideoEnhance, Blitter

## Supported Generations

- **Gen8+** (Broadwell and newer) - Full support with iHD
- **Gen7** (Haswell) - Limited support
- **Gen6 and older** - Use i965 driver

---

**See Also:**
- [hardware-acceleration.nix](../hardware-acceleration.nix) - Configuration
- [mpv.nix](../../configs/media/mpv.nix) - MPV setup

**Status:** ✅ Fully Configured | **Driver:** iHD | **VA-API:** Enabled | **Vulkan:** Enabled | **OpenCL:** Enabled
