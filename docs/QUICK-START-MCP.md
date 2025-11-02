# Quick Start: MCP Configuration

## 🚀 5-Minute Setup

### Step 1: Apply Cursor Update Fix

Rebuild your Home Manager configuration to apply the Cursor update fix:

```bash
cd /workspace

# Rebuild Home Manager (this will take a few minutes)
nix run home-manager/master -- switch --flake .#pixel-peeper@alucard
```

### Step 2: Configure Cursor for MCP

**Option A: Via Cursor Settings UI** (Recommended)
1. Open Cursor
2. Press `Ctrl+,` (Settings)
3. Search for "MCP" or "Model Context Protocol"
4. Set config path: `/workspace/mcp-config.json`
5. Restart Cursor

**Option B: Via Command Line**
```bash
# Create Cursor config directory
mkdir -p ~/.config/Cursor/User

# Link the MCP config
ln -sf /workspace/mcp-config.json ~/.config/Cursor/User/mcp-config.json

# Restart Cursor
```

### Step 3: Fix Cursor Update Notifications

**After rebuilding Home Manager:**

1. **Manual Fix** (Immediate):
   - Open Cursor Settings (`Ctrl+,`)
   - Search for "update"
   - Set "Update: Mode" to "manual"
   - Uncheck "Update: Enable Notifications"

2. **Or Copy Product Config** (Persistent):
   ```bash
   mkdir -p ~/.config/Cursor
   cp /nix/store/*/share/cursor-default-config/product.json ~/.config/Cursor/product.json
   ```

### Step 4: Test MCP

1. Restart Cursor
2. Open this dotfiles folder
3. Try these commands in Cursor:
   - "Using MCP, show me the files in /workspace/configs/desktop/hyprland"
   - "Using MCP, what are my recent git commits?"
   - "Using MCP, read my Obsidian notes about NixOS" (if vault exists)

## 🔑 Optional: Add API Keys

### Brave Search (for NixOS docs search)
1. Get key: https://brave.com/search/api/
2. Edit `/workspace/mcp-config.json`:
   ```json
   "BRAVE_API_KEY": "your-key-here"
   ```

### GitHub (for PR/Issue management)
1. Generate token: https://github.com/settings/tokens
2. Scopes needed: `repo`, `read:org`, `read:user`
3. Edit `/workspace/mcp-config.json`:
   ```json
   "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your-token-here"
   ```

### Obsidian
Current path in config: `/home/pixel-peeper/Documents/secend-brain`

If your vault is elsewhere:
```bash
# Edit mcp-config.json and update the path
nano /workspace/mcp-config.json
```

## ✅ Verification Checklist

### After Home Manager Rebuild:
- [ ] Cursor package updated with update fix
- [ ] No build errors
- [ ] Cursor still launches

### After MCP Configuration:
- [ ] Cursor recognizes MCP config
- [ ] Can see MCP tools in Cursor
- [ ] Filesystem operations work
- [ ] Git operations work

### After Update Fix:
- [ ] No more "update available" notifications
- [ ] Settings show update mode as "manual"

## 🎯 What's Working Now

| Feature | Status | Description |
|---------|--------|-------------|
| 📁 Filesystem | ✅ Ready | Access dotfiles & home directory |
| 🔀 Git | ✅ Ready | Git operations on repository |
| 🌐 Fetch | ✅ Ready | Fetch NixOS documentation |
| 🎭 Puppeteer | ✅ Ready | Browser automation |
| 📝 Obsidian | ⚠️ Check Path | Vault at `/home/pixel-peeper/Documents/secend-brain` |
| 🔍 Brave Search | ⚠️ API Key | Requires API key |
| 🐙 GitHub | ⚠️ Token | Requires PAT |

## 🎯 What You Can Do Now

### Dotfiles Management
```
"Show me all Hyprland configuration files"
"What keybindings are defined in keybindings.nix?"
"Find all references to 'catppuccin' in the configs"
"Read the cursor.nix file and explain what it does"
```

### Git Operations
```
"Show me recent commits"
"What files changed in the last commit?"
"Show git status of this repository"
"Create a new branch for MCP testing"
```

### NixOS Help
```
"Fetch the NixOS manual page for systemd.services"
"Search for 'hyprland wayland' configuration examples"
"Read docs/DECISIONS.md and summarize it"
```

### Obsidian (if configured)
```
"Show me my Obsidian notes about NixOS"
"Create a new note about Cursor MCP setup"
"Search my vault for docker-related notes"
```

## 🚨 Troubleshooting

### MCP Not Loading
```bash
# Check Node.js
node --version

# Test config syntax
jq . /workspace/mcp-config.json

# Check Cursor logs
# Help → Toggle Developer Tools → Console
```

### Obsidian MCP Fails
```bash
# Verify vault path
ls -la /home/pixel-peeper/Documents/secend-brain

# If path is wrong, edit config:
nano /workspace/mcp-config.json
```

### Update Notifications Still Appear
```bash
# Clear Cursor cache
rm -rf ~/.config/Cursor/Cache
rm -rf ~/.config/Cursor/CachedData

# Re-copy product.json
cp /nix/store/*/share/cursor-default-config/product.json ~/.config/Cursor/

# Restart Cursor
```

## 🚀 Next Steps

1. ✅ **Done**: Cursor update fix configured
2. ✅ **Done**: MCP configuration created
3. ✅ **Done**: Documentation written
4. 🔄 **Now**: Apply changes (rebuild Home Manager)
5. 🔄 **Now**: Configure Cursor to use MCP
6. 🔧 **Optional**: Add API keys for Brave/GitHub
7. 🎨 **Optional**: Explore custom MCPs (see `docs/MCP-SUGGESTIONS.md`)
8. 💾 **Optional**: Commit changes to git

## 📖 More Info

- **Full Setup Guide**: `docs/MCP-SETUP.md`
- **Custom MCPs**: `docs/MCP-SUGGESTIONS.md`
- **Cursor Update Fix**: `docs/CURSOR-UPDATE-FIX.md`

---

**Need help?** Check the full documentation or ask Cursor with MCP enabled! 🎉
