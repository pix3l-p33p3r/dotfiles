# Quick Start: MCP Configuration

## 🚀 5-Minute Setup

### Step 1: Copy and Configure MCP

```bash
cd /workspace

# Copy the example config
cp mcp-config.example.json mcp-config.json

# Edit with your API keys (optional for basic functionality)
# The filesystem, git, and docs MCPs work without API keys!
```

### Step 2: Configure Cursor

**Option A: Via Cursor Settings UI**
1. Open Cursor
2. Press `Ctrl+,` (Settings)
3. Search for "MCP" or "Model Context Protocol"
4. Set config path: `/workspace/mcp-config.json`
5. Restart Cursor

**Option B: Via Home Manager (NixOS Way)**

Add to `homes/pixel-peeper/default.nix`:
```nix
home.file.".config/Cursor/User/mcp-config.json".source = ../../mcp-config.json;
```

Then rebuild:
```bash
nix run home-manager/master -- switch --flake .#pixel-peeper@alucard
```

### Step 3: Fix Cursor Update Notifications

**Immediate Fix** (Manual):
1. Open Cursor Settings (`Ctrl+,`)
2. Search for "update"
3. Set "Update: Mode" to "manual"
4. Disable "Update: Enable Notifications"

**Persistent Fix** (After rebuilding Home Manager):
```bash
# The cursor.nix has been updated, rebuild to apply
nix run home-manager/master -- switch --flake .#pixel-peeper@alucard

# Then restart Cursor
```

### Step 4: Test MCP

1. Open Cursor
2. Open this dotfiles folder
3. Ask Cursor: "Using MCP, show me the files in /workspace/configs/desktop/hyprland"
4. Or: "Using MCP, what are my recent git commits?"

## 🔑 Optional: Add API Keys

### Brave Search (for NixOS docs search)
1. Get key: https://brave.com/search/api/
2. Edit `mcp-config.json`:
   ```json
   "BRAVE_API_KEY": "your-key-here"
   ```

### GitHub (for PR/Issue management)
1. Generate token: https://github.com/settings/tokens
2. Scopes needed: `repo`, `read:org`, `read:user`
3. Edit `mcp-config.json`:
   ```json
   "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your-token-here"
   ```

### Obsidian (if you use it)
1. Find your vault path: Usually `~/Documents/Obsidian` or `~/Obsidian`
2. Edit `mcp-config.json`:
   ```json
   "OBSIDIAN_VAULT_PATH": "/full/path/to/vault"
   ```

## ✅ Verification

### Check MCP is Working

In Cursor, you should see MCP tools available:
- 📁 Filesystem operations
- 🔀 Git operations
- 🌐 Web fetch (docs)
- 🔍 Brave Search (if configured)
- 📝 Obsidian (if configured)
- 🐙 GitHub (if configured)

### Troubleshoot

**MCP not loading?**
```bash
# Check Node.js is available
which node
node --version

# Check config syntax
jq . /workspace/mcp-config.json
```

**Check Cursor logs:**
- Help → Toggle Developer Tools → Console
- Look for MCP-related messages

## 📚 What's Configured

### ✅ Working Out of the Box

| MCP | Status | Purpose |
|-----|--------|---------|
| Filesystem | ✅ Ready | Access dotfiles and home directory |
| Git | ✅ Ready | Git operations on your repository |
| Fetch | ✅ Ready | Fetch NixOS documentation |
| Puppeteer | ✅ Ready | Browser automation |

### ⚠️ Needs Configuration

| MCP | Needs | Purpose |
|-----|-------|---------|
| Brave Search | API Key | Search NixOS docs & packages |
| GitHub | PAT | Manage issues & PRs |
| Obsidian | Vault Path | Access your notes |

## 🎯 What You Can Do Now

With MCP configured, you can ask Cursor to:

### Dotfiles Management
- "Show me all Hyprland configuration files"
- "What keybindings are defined in keybindings.nix?"
- "Find all references to 'catppuccin' in the configs"

### Git Operations
- "Show me recent commits"
- "What files changed in the last commit?"
- "Show git status of this repository"

### NixOS Help
- "Fetch the NixOS manual page for systemd.services"
- "Search for 'hyprland wayland' in nixpkgs" (needs Brave Search)

### Documentation
- "Read the DECISIONS.md file"
- "What's documented in the docs folder?"

## 🚀 Next Steps

1. ✅ Set up basic MCPs (done!)
2. 🔑 Add API keys (optional)
3. 🎨 Try custom MCPs from `docs/MCP-SUGGESTIONS.md`
4. 📝 Add more specialized MCPs for your workflow

## 📖 More Info

- **Full Setup Guide**: `docs/MCP-SETUP.md`
- **Custom MCPs**: `docs/MCP-SUGGESTIONS.md`
- **Cursor Update Fix**: `docs/CURSOR-UPDATE-FIX.md`

---

**Need help?** Check the full documentation or open an issue.
