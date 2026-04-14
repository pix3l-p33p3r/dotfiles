# Intel Hardware Acceleration — Alucard

ThinkPad with Intel Gen12 Tiger Lake Iris Xe (TGL GT2), single iGPU, Hyprland/Wayland.

**NixOS config:** `machines/alucard/hardware-acceleration.nix` (sole GPU module — `graphics.nix` removed).

## What's enabled

| Stack | Detail |
|-------|--------|
| VA-API | H.264/HEVC/VP8/VP9 decode+encode, AV1 decode; driver: **iHD** (`intel-media-driver`) |
| Vulkan | Mesa iris |
| OpenCL | Intel Compute Runtime (NEO) + Level Zero |
| VDPAU | via `va_gl` (for legacy apps) |

## Verification

```bash
vainfo              # "iHD driver" + codec list
vulkaninfo --summary
clinfo
intel_gpu_top       # live engine stats (Video, Render/3D, Blitter…)
```

A modest **Video %** in `intel_gpu_top` during 1080p playback is expected and correct.

## Application notes

All apps inherit VA-API from NixOS session env (`LIBVA_DRIVER_NAME=iHD`, `VDPAU_DRIVER=va_gl`).

**mpv** — configured in `configs/media/mpv.nix` with `hwdec=auto-copy`, `vo=gpu-next`, Vulkan/Wayland context.

**Firefox** — `MOZ_DISABLE_RDD_SANDBOX=1` set via NixOS. Check `about:support → Graphics` for `HARDWARE_VIDEO_DECODING: available`. Declarative `about:config` prefs are a deferred dotfiles task.

**Chrome** — VA-API/Vulkan flags set in `configs/browsers/chrome.nix`.

**ffmpeg** — picks up VA-API env; explicit encode: `ffmpeg -i in.mp4 -c:v h264_vaapi out.mp4`.

**VLC** — enable hardware-accelerated decoding in Preferences → Video → Output / Codec settings.

## Troubleshooting

```bash
echo $LIBVA_DRIVER_NAME   # iHD
groups                    # video render
ls /dev/dri/              # card0, renderD128
lsmod | grep i915
```

Firefox VA-API: check `about:config` → `media.ffmpeg.vaapi` is `true`; `about:support → Media → codecSupportInfo` should list `HWDEC`.
