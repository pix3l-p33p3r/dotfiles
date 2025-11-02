# Cursor Update Notification Fix

## The Problem

Cursor shows an "update available" notification even though the app is managed by Nix. This happens because:

1. **Version Pinning**: Your `cursor.nix` pins version `2.0.34`
2. **Managed Installation**: Nix controls the AppImage, preventing manual updates
3. **Update Checks**: Cursor still checks for updates online

## The Solution

There are three approaches to fix this:

### ✅ Option 1: Disable Update Checks (Recommended)

Update your Cursor settings to disable automatic update checks.

**Manual Method** (Immediate):
1. Open Cursor
2. Press `Ctrl+,` for Settings
3. Search for "update"
4. Set "Update Mode" to "manual"
5. Disable "Enable Update Notifications"

**NixOS Method** (Persistent):
The `cursor.nix` has been updated to include update configuration. Rebuild your system:

```bash
# Update home manager
nix run home-manager/master -- switch --flake .#pixel-peeper@alucard
```

Then manually copy the product.json:
```bash
mkdir -p ~/.config/Cursor
cp /nix/store/*/share/cursor-default-config/product.json ~/.config/Cursor/product.json
```

### 🔄 Option 2: Update Cursor Version

Keep auto-updates enabled but update to the latest version in Nix.

**Steps**:

1. **Find latest version**:
   Visit [Cursor Downloads](https://cursor.sh/downloads) or check their releases.

2. **Update `cursor.nix`**:
   ```nix
   let
     pname = "cursor";
     version = "X.X.XX";  # Update this
     
     src = fetchurl {
       url = "https://downloads.cursor.com/production/HASH/linux/x64/Cursor-${version}-x86_64.AppImage";
       sha256 = "...";  # Update this
     };
   ```

3. **Get new hash**:
   ```bash
   # Download the new AppImage
   nix-prefetch-url https://downloads.cursor.com/production/HASH/linux/x64/Cursor-X.X.XX-x86_64.AppImage
   ```

4. **Rebuild**:
   ```bash
   nix run home-manager/master -- switch --flake .#pixel-peeper@alucard
   ```

### 🚫 Option 3: Ignore Notifications

Simply dismiss the notification each time. Not ideal but simplest if updates aren't critical.

## Recommended Approach

**For this setup, use Option 1** because:
- ✅ Consistent with NixOS philosophy (declarative, reproducible)
- ✅ No annoying notifications
- ✅ You control when to update via flake
- ✅ Prevents Cursor from downloading updates automatically

## Keeping Cursor Updated (Nix Way)

To update Cursor in your NixOS config:

1. **Check for new versions**:
   ```bash
   # Manual check
   curl -s https://cursor.sh/downloads | grep -o 'version.*[0-9]\+\.[0-9]\+\.[0-9]\+'
   ```

2. **Update `cursor.nix`** with new version and hash

3. **Test before switching**:
   ```bash
   # Build but don't activate
   nix build .#homeConfigurations.pixel-peeper@alucard.activationPackage
   ```

4. **Apply update**:
   ```bash
   nix run home-manager/master -- switch --flake .#pixel-peeper@alucard
   ```

## Automation Ideas

### Auto-update Script

Create `scripts/update-cursor.sh`:
```bash
#!/usr/bin/env bash
# Fetch latest Cursor version and update cursor.nix

LATEST_VERSION=$(curl -s https://api.github.com/repos/getcursor/cursor/releases/latest | jq -r .tag_name)
DOWNLOAD_URL="https://downloads.cursor.com/production/HASH/linux/x64/Cursor-${LATEST_VERSION}-x86_64.AppImage"

echo "Latest version: $LATEST_VERSION"
echo "Downloading to get hash..."

HASH=$(nix-prefetch-url "$DOWNLOAD_URL")

echo "Hash: $HASH"
echo "Update cursor.nix with:"
echo "  version = \"$LATEST_VERSION\";"
echo "  sha256 = \"$HASH\";"
```

### Flake Input (Alternative)

Instead of pinning in `cursor.nix`, use a flake input:

```nix
# In flake.nix
inputs = {
  cursor = {
    url = "https://cursor.sh/downloads/linux";
    flake = false;
  };
};
```

But this is more complex and less common for AppImages.

## Why This Matters

**NixOS Benefits**:
- Rollback if update breaks something
- Reproducible across machines
- Declarative version management
- No surprise updates

**Cursor Updates Conflict**:
- Cursor wants to auto-update
- Nix wants to manage packages
- Result: Notification spam

**Solution**: Disable Cursor's updater, use Nix for updates.

## Verification

After applying the fix:

1. **Check settings**:
   ```bash
   cat ~/.config/Cursor/product.json
   ```
   Should show:
   ```json
   {
     "updateUrl": "",
     "updateMode": "manual"
   }
   ```

2. **Restart Cursor**

3. **Verify no update notifications appear**

## Troubleshooting

### Update Notification Still Appears

1. Clear Cursor cache:
   ```bash
   rm -rf ~/.config/Cursor/Cache
   rm -rf ~/.config/Cursor/CachedData
   ```

2. Reset settings:
   ```bash
   rm ~/.config/Cursor/product.json
   cp /nix/store/*/share/cursor-default-config/product.json ~/.config/Cursor/
   ```

3. Restart Cursor

### Cursor Won't Launch After Update

Roll back:
```bash
# List generations
home-manager generations

# Rollback to previous generation
/nix/store/OLD-GENERATION/activate
```

Or use previous version in `cursor.nix`.

## Additional Notes

- **AppImage Location**: Managed by Nix in `/nix/store`
- **Config Location**: `~/.config/Cursor`
- **User Data**: `~/.cursor-tutor` (preserved across updates)
- **Extensions**: `~/.cursor/extensions` (preserved)

## Related Files

- `configs/editors/cursor.nix` - Package definition
- `homes/pixel-peeper/default.nix` - Home Manager config
- `.cursorrules` - Cursor AI rules for this project

---

**Questions?** Check the [NixOS Wiki](https://wiki.nixos.org) or open an issue.
