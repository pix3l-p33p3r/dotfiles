# Model Context Protocol (MCP) Setup

MCP servers provide Cursor AI with enhanced context and capabilities for your codebase, tools, and services.

## Configuration

**Location**: Managed declaratively at `configs/editors/cursor-config.nix`  
**Generated to**: `~/.cursor/mcp.json`  
**Updates**: Automatic on `home-manager switch`

## Active MCP Servers

### 1. Filesystem (`@modelcontextprotocol/server-filesystem`)
✅ **Active** | Access to `/home/pixel-peeper/dotfiles`

### 2. NixOS (`github:utensils/mcp-nixos`)
✅ **Active** | NixOS-specific operations and package search

### 3. Obsidian (`obsidian-mcp-server`)
✅ **Active** | Vault: `/home/pixel-peeper/Documents/secend-brain`  
Uses SOPS-encrypted API key from `secrets/users/pixel-peeper.yaml`

### 4. GitKraken (GitLens integration)
✅ **Active** | Enhanced Git operations via GitLens

## Troubleshooting

**MCP not loading?**
- Check Cursor logs: Help → Toggle Developer Tools → Console
- Verify config: `cat ~/.cursor/mcp.json`
- Ensure Node.js installed: `node --version`

**Permission errors?**
- Check dotfiles access: `ls -la ~/dotfiles`

**Obsidian connection issues?**
- Verify Local REST API plugin is running in Obsidian
- Check API key in SOPS: `sops secrets/users/pixel-peeper.yaml`

## Security

- **API keys via SOPS** - Obsidian credentials encrypted in `secrets/`
- **Limited filesystem access** - Only dotfiles directory accessible
- **No external API calls** - All MCP servers are local/private

## Resources

- [MCP Documentation](https://modelcontextprotocol.io)
- [Available Servers](https://github.com/modelcontextprotocol/servers)
- [NixOS MCP](https://github.com/utensils/mcp-nixos)
