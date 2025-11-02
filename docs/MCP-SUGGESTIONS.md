# Custom MCP Suggestions for Your NixOS Stack

Based on your dotfiles configuration, here are tailored MCP server suggestions to enhance your workflow.

## 🎯 Highly Recommended MCPs

### 1. **NixOS/Nix-specific MCP**

Create a custom MCP for Nix operations:

```json
{
  "nix-helper": {
    "command": "node",
    "args": ["/workspace/scripts/mcp/nix-helper.js"],
    "description": "Nix flake operations, package search, and option lookup"
  }
}
```

**Capabilities**:
- Search nixpkgs for packages
- Query NixOS options
- Validate Nix syntax
- Run `nix flake check`
- Search Home Manager options
- Format Nix code with `nixfmt`

**Implementation** (create as `/workspace/scripts/mcp/nix-helper.js`):
```javascript
#!/usr/bin/env node
// Custom MCP server for Nix operations
const { spawn } = require('child_process');

// Implement MCP protocol
// Tools: search-packages, check-flake, format-nix, query-options
```

### 2. **Hyprland Configuration MCP**

For managing Hyprland-specific configurations:

```json
{
  "hyprland-config": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-filesystem", "/workspace/configs/desktop/hyprland"],
    "description": "Dedicated access to Hyprland configuration files"
  }
}
```

### 3. **Secrets Manager MCP (SOPS)**

Custom MCP for managing encrypted secrets:

```json
{
  "sops-secrets": {
    "command": "bash",
    "args": ["/workspace/scripts/mcp/sops-helper.sh"],
    "description": "SOPS secret encryption/decryption operations"
  }
}
```

**Capabilities**:
- List encrypted secrets
- Decrypt secrets (with age key)
- Encrypt new secrets
- Validate SOPS files
- Rotate keys

### 4. **Docker/Kubernetes MCP**

Since you have Docker and K9s in your stack:

```json
{
  "docker": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-docker"],
    "description": "Docker container management"
  },
  "kubernetes": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-kubernetes"],
    "description": "Kubernetes cluster operations via kubectl"
  }
}
```

### 5. **Media Library MCP**

For managing your media files and MPD:

```json
{
  "media-library": {
    "command": "npx",
    "args": [
      "-y",
      "@modelcontextprotocol/server-filesystem",
      "/home/pixel-peeper/Music",
      "/home/pixel-peeper/Videos"
    ],
    "description": "Access to media library for MPD/MPV"
  }
}
```

## 🚀 Development Workflow MCPs

### 6. **Terraform MCP**

Since terraform is in your stack:

```json
{
  "terraform": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-terraform"],
    "description": "Terraform infrastructure as code operations"
  }
}
```

### 7. **Security Tools MCP**

Custom MCP for your security tools (trivy, semgrep, nuclei):

```json
{
  "security-scan": {
    "command": "bash",
    "args": ["/workspace/scripts/mcp/security-helper.sh"],
    "description": "Run security scans with trivy, semgrep, and nuclei"
  }
}
```

**Create** `/workspace/scripts/mcp/security-helper.sh`:
```bash
#!/usr/bin/env bash
# MCP wrapper for security tools
case "$1" in
  trivy) trivy fs /workspace ;;
  semgrep) semgrep scan --config auto /workspace ;;
  nuclei) nuclei -target "$2" ;;
esac
```

### 8. **LazyGit MCP**

Wrapper for lazygit operations:

```json
{
  "lazygit": {
    "command": "lazygit",
    "args": ["-p", "/workspace"],
    "description": "Terminal UI for git operations"
  }
}
```

## 📝 Documentation & Knowledge MCPs

### 9. **Neovim Config MCP**

Dedicated access to your Neovim configuration:

```json
{
  "neovim-config": {
    "command": "npx",
    "args": [
      "-y",
      "@modelcontextprotocol/server-filesystem",
      "/workspace/configs/terminal/nvim"
    ],
    "description": "Neovim configuration management"
  }
}
```

### 10. **Documentation Search MCP**

Search across your docs/ directory:

```json
{
  "docs-search": {
    "command": "npx",
    "args": [
      "-y",
      "@modelcontextprotocol/server-filesystem",
      "/workspace/docs"
    ],
    "description": "Search and manage documentation files"
  }
}
```

## 🎨 Creative/Media MCPs

### 11. **Wallpaper Manager MCP**

Manage your wallpapers collection:

```json
{
  "wallpapers": {
    "command": "npx",
    "args": [
      "-y",
      "@modelcontextprotocol/server-filesystem",
      "/workspace/assets/wallpapers"
    ],
    "description": "Wallpaper collection management for Hyprpaper"
  }
}
```

### 12. **MPD/Music MCP**

Control MPD via MCP:

```json
{
  "mpd": {
    "command": "bash",
    "args": ["/workspace/scripts/mcp/mpd-helper.sh"],
    "description": "MPD music player control"
  }
}
```

## 🔧 System Management MCPs

### 13. **NixOS Generations MCP**

Manage system generations:

```json
{
  "nix-generations": {
    "command": "bash",
    "args": ["/workspace/scripts/mcp/generations-helper.sh"],
    "description": "List, diff, and rollback NixOS generations"
  }
}
```

### 14. **System Monitor MCP**

System stats and monitoring:

```json
{
  "system-monitor": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-system"],
    "description": "System resources and process monitoring"
  }
}
```

## 🌐 Web Development MCPs

### 15. **Browser Testing MCP**

Since you have Firefox and Chromium configured:

```json
{
  "browser-test": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-puppeteer"],
    "description": "Automated browser testing"
  }
}
```

## 📦 Package Management MCPs

### 16. **Flake Lock MCP**

Monitor and update flake inputs:

```json
{
  "flake-lock": {
    "command": "bash",
    "args": ["/workspace/scripts/mcp/flake-helper.sh"],
    "description": "Manage flake.lock and update inputs"
  }
}
```

**Create** `/workspace/scripts/mcp/flake-helper.sh`:
```bash
#!/usr/bin/env bash
cd /workspace
case "$1" in
  update) nix flake update ;;
  check) nix flake check ;;
  show) nix flake show ;;
  metadata) nix flake metadata ;;
esac
```

## 🔐 Vault/Secrets MCPs

### 17. **Vault MCP**

Since vault is in your stack:

```json
{
  "vault": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-vault"],
    "env": {
      "VAULT_ADDR": "http://localhost:8200",
      "VAULT_TOKEN": "YOUR_VAULT_TOKEN"
    },
    "description": "HashiCorp Vault secret management"
  }
}
```

## 📊 Monitoring & Analytics MCPs

### 18. **Btop/Battop Integration**

System monitoring data:

```json
{
  "system-stats": {
    "command": "bash",
    "args": ["/workspace/scripts/mcp/stats-helper.sh"],
    "description": "System statistics and resource usage"
  }
}
```

## 🎮 Custom Project MCPs

### 19. **Dotfiles Helper MCP**

All-in-one MCP for common dotfiles operations:

```json
{
  "dotfiles-helper": {
    "command": "node",
    "args": ["/workspace/scripts/mcp/dotfiles-helper.js"],
    "description": "Common dotfiles operations: rebuild, test, rollback"
  }
}
```

**Capabilities**:
- `nixos-rebuild test`
- `home-manager switch`
- List generations
- Diff configurations
- Validate Nix syntax
- Format all Nix files

## 🎯 Implementation Priority

Based on your workflow, implement in this order:

1. **Tier 1 (Essential)**:
   - ✅ Filesystem (already configured)
   - ✅ Git (already configured)
   - Nix Helper
   - Dotfiles Helper

2. **Tier 2 (High Value)**:
   - SOPS Secrets
   - Flake Lock Manager
   - Security Scan
   - NixOS Generations

3. **Tier 3 (Convenience)**:
   - Docker/Kubernetes
   - Terraform
   - Hyprland Config
   - Neovim Config

4. **Tier 4 (Optional)**:
   - Media Library
   - Wallpapers
   - MPD Control
   - System Monitor

## 📝 Creating Custom MCPs

### Template for Custom MCP

```javascript
#!/usr/bin/env node
// /workspace/scripts/mcp/template.js

const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// MCP Protocol implementation
const tools = {
  'tool-name': {
    description: 'Tool description',
    parameters: {},
    execute: async (params) => {
      // Tool implementation
      return { result: 'success' };
    }
  }
};

// Listen for MCP protocol messages
rl.on('line', async (line) => {
  const message = JSON.parse(line);
  // Handle MCP protocol
});

console.error('MCP server started');
```

### Testing Custom MCPs

```bash
# Test MCP server directly
node /workspace/scripts/mcp/your-mcp.js

# Test with Cursor
# Add to mcp-config.json and restart Cursor
```

## 🔗 Useful MCP Resources

- [Official MCP Servers](https://github.com/modelcontextprotocol/servers)
- [MCP Protocol Spec](https://spec.modelcontextprotocol.io/)
- [Creating Custom MCPs](https://modelcontextprotocol.io/docs/create)
- [NixOS Search](https://search.nixos.org/)
- [Home Manager Options](https://home-manager-options.extranix.com/)

## 🚀 Next Steps

1. Copy `mcp-config.example.json` to `mcp-config.json`
2. Fill in API keys for Brave Search and GitHub
3. Update Obsidian vault path
4. Add custom MCPs based on priorities above
5. Test each MCP individually
6. Configure Cursor to use the MCP config

---

**Questions?** Check `docs/MCP-SETUP.md` for detailed setup instructions.
