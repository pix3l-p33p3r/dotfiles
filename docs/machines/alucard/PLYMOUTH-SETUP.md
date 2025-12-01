# Plymouth Boot Splash Configuration

Custom Catppuccin-Alucard theme with enhanced LUKS prompts for Alucard.

## ✨ Current Setup

**Custom Theme**: Catppuccin-Alucard

- Built from Catppuccin Mocha with mauve accents (#b4befe)
- Alucard wallpaper as background/watermark
- Custom LUKS prompt: "Decrypting - Alucard"
- Rosewater throbber (#f5e0dc), HiDPI scaling (1.2x)

**LUKS Integration**:

- Themed password prompts via `systemd-ask-password-plymouth`
- 3 retry attempts, graceful console fallback
- Requires `boot.initrd.systemd.enable = true`

## 🔧 Implementation

Theme built in-flake using `pkgs.runCommand`:

1. Copies Catppuccin Mocha base theme
2. Recolors assets to mauve/rosewater via ImageMagick
3. Generates background/watermark from `assets/wallpapers/alucard.jpg`
4. Creates `catppuccin-alucard.plymouth` config

**Key Config** (`boot.nix`):

```nix
boot.plymouth = {
  enable = true;
  theme = "catppuccin-alucard";
  themePackages = [ catppuccinAlucardPlymouth ];
  extraConfig = ''
    ShowDelay=0
    DeviceScale=1.2
  '';
};

boot.initrd.systemd.enable = true;  # Required for LUKS prompts
```

## 🎯 Why systemd Initrd?

`boot.initrd.systemd.enable = true` is **required** for:

- Plymouth during LUKS unlock
- `systemd-ask-password-plymouth` integration
- Themed prompts (not console fallback)

Without it, Plymouth won't show during LUKS unlock.

## 🔍 Verification

```bash
plymouth-set-default-theme --list  # Should show catppuccin-alucard
systemctl status plymouth-start.service
```


## 🐛 Troubleshooting

**Plymouth doesn't show during LUKS unlock:**

- Verify `boot.initrd.systemd.enable = true`
- Check `cat /proc/cmdline | grep splash`

**Black screen:**

- Ensure `boot.initrd.kernelModules = [ "i915" ]` is set

**Console messages visible:**

- Check `boot.consoleLogLevel = 0` and `boot.kernelParams` include `"quiet" "splash"`

## 📊 Compatibility

| Feature | Status |
|---------|--------|
| Lanzaboote/Secure Boot | ✅ Yes |
| LUKS encryption | ✅ Yes (themed prompts) |
| Intel graphics | ✅ Yes (i915) |
| Wayland/X11 | ✅ Yes |

**Status**: ✅ Configured | **Theme**: Catppuccin-Alucard | **LUKS**: Themed prompts
