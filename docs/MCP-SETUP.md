# Model Context Protocol (MCP) Setup

This document explains the MCP configuration for Cursor AI integration with your NixOS dotfiles.

## Overview

MCP servers provide Cursor with enhanced context and capabilities for working with your codebase, external tools, and services.

## Configuration File

The main MCP configuration is in `/workspace/mcp-config.json`.

## Configured MCP Servers

### 1. **Filesystem** (`@modelcontextprotocol/server-filesystem`)
**Status**: ✅ Ready to use  
**Purpose**: Direct access to your dotfiles and home directory  
**Paths**:
- `/workspace` - Your NixOS configuration
- `/home/pixel-peeper` - Your home directory

**Use cases**:
- Reading/writing configuration files
- Browsing directory structure
- File operations within allowed paths

### 2. **Git** (`@modelcontextprotocol/server-git`)
**Status**: ✅ Ready to use  
**Purpose**: Git operations on your dotfiles repository  
**Repository**: `/workspace`

**Capabilities**:
- View commit history
- Show diffs
- Check git status
- Manage branches
- Create commits

### 3. **Brave Search** (`@modelcontextprotocol/server-brave-search`)
**Status**: ⚠️ Requires API key  
**Purpose**: Search for NixOS documentation, packages, and solutions  

**Setup**:
1. Get API key from [Brave Search API](https://brave.com/search/api/)
2. Update `BRAVE_API_KEY` in `mcp-config.json`

### 4. **NixOS Docs** (`@modelcontextprotocol/server-fetch`)
**Status**: ✅ Ready to use  
**Purpose**: Fetch NixOS and Home Manager documentation

**Use cases**:
- Look up NixOS options
- Check Home Manager modules
- Fetch package information from nixpkgs

### 5. **Obsidian** (`@executeautomation/mcp-obsidian`)
**Status**: ✅ Configured for your vault  
**Purpose**: Interact with your Obsidian notes vault  
**Vault Path**: `/home/pixel-peeper/Documents/secend-brain`

**Capabilities**:
- Read notes
- Create new notes
- Search vault
- Link references

### 6. **GitHub** (`@modelcontextprotocol/server-github`)
**Status**: ⚠️ Requires personal access token  
**Purpose**: GitHub repository management

**Setup**:
1. Generate a GitHub PAT at [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
2. Required scopes: `repo`, `read:org`, `read:user`
3. Update `GITHUB_PERSONAL_ACCESS_TOKEN` in `mcp-config.json`

**Capabilities**:
- Create/manage issues
- Review pull requests
- Search repositories
- Manage releases

### 7. **Puppeteer** (`@modelcontextprotocol/server-puppeteer`)
**Status**: ✅ Ready to use  
**Purpose**: Browser automation for testing

**Use cases**:
- Test Hyprland web applications
- Automate browser tasks
- Screenshot generation
- Web scraping

## Installing MCP Configuration

### Option 1: Cursor Settings (Recommended)

1. Open Cursor
2. Go to Settings (`Ctrl+,`)
3. Search for "MCP"
4. Point to the config file: `/workspace/mcp-config.json`

### Option 2: Copy to Cursor Config Directory

```bash
# Create Cursor config directory if it doesn't exist
mkdir -p ~/.config/Cursor/User

# Link the MCP config
ln -sf /workspace/mcp-config.json ~/.config/Cursor/User/mcp-config.json
```

### Option 3: Add to Home Manager (NixOS Way) ✅ ACTIVE

**Status**: Already configured declaratively at `configs/editors/cursor-config.nix`

The MCP configuration is managed declaratively through Home Manager:
- Configuration: `configs/editors/cursor-config.nix`
- Imported in: `homes/pixel-peeper/default.nix`
- Generated to: `~/.cursor/mcp.json`

This is The Way™ - your MCP config is now part of your dotfiles and will be automatically deployed on `home-manager switch`.

## Future MCP Ideas

Based on your stack, here are potential MCP servers to consider:

### Development Tools
- **Docker/Kubernetes** - Container and cluster management (for k9s workflow)
- **Terraform** - Infrastructure as code operations
- **Security Scanner** - Integrate trivy, semgrep, nuclei scans

### System Management
- **NixOS Generations** - List, diff, and rollback system generations
- **Flake Manager** - Update and manage flake.lock inputs
- **SOPS Helper** - Encrypt/decrypt secrets via MCP

### Workflow Enhancement
- **Media Library** - Access to Music/Videos for MPD/MPV
- **Documentation Search** - Dedicated search for your docs/ directory
- **Dotfiles Helper** - Common operations: rebuild, test, validate, format

See archived `MCP-SUGGESTIONS.md` in git history for detailed implementation examples.

## Troubleshooting

### MCP Server Not Loading
1. Ensure Node.js and npm are installed:
   ```bash
   node --version
   npm --version
   ```

2. Check Cursor logs:
   - Help → Toggle Developer Tools → Console

3. Verify MCP config syntax:
   ```bash
   jq . /workspace/mcp-config.json
   ```

### Permission Errors
Ensure the filesystem MCP has access to the required paths:
```bash
ls -la /workspace
ls -la /home/pixel-peeper
```

### API Key Issues
- Brave Search: Verify key at https://brave.com/search/api/
- GitHub: Regenerate token and check scopes

## Security Notes

1. **API Keys**: Never commit API keys to git
   - Add to `.gitignore`: `mcp-config.json` (keep a `mcp-config.example.json`)
   - Or use SOPS encryption: Store keys in `secrets/`

2. **Filesystem Access**: MCP servers have full access to specified paths
   - Only grant access to necessary directories
   - Avoid adding `/` or sensitive system paths

3. **Network Access**: Some MCPs make external requests
   - Review server code before using
   - Monitor network activity

## Resources

- [MCP Official Documentation](https://modelcontextprotocol.io)
- [Cursor MCP Guide](https://cursor.sh/mcp)
- [Available MCP Servers](https://github.com/modelcontextprotocol/servers)
- [NixOS Options Search](https://search.nixos.org)

## Updates

MCP servers are managed via npm/npx. They auto-update when using `npx -y` flag.

To pin versions:
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem@1.0.0",
        "/workspace"
      ]
    }
  }
}
```

---

**Need help?** Check the [MCP troubleshooting guide](https://modelcontextprotocol.io/docs/troubleshooting) or open an issue.
