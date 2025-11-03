{ config, pkgs, lib, ... }:
{
  # Declarative Cursor AI Editor configuration
  # The One True Way™ - managed by Home Manager
  # Secrets managed with SOPS + Age encryption
  
  # Generate mcp.json at activation time (after secrets are decrypted)
  home.activation.generateCursorMcpConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $HOME/.cursor
    
    # Read secrets from SOPS-decrypted files
    OBSIDIAN_API_KEY=$(cat ${config.sops.secrets."obsidian/api_key".path} 2>/dev/null || echo "")
    OBSIDIAN_BASE_URL=$(cat ${config.sops.secrets."obsidian/base_url".path} 2>/dev/null || echo "https://127.0.0.1:27124")
    
    # Generate mcp.json with secrets
    $DRY_RUN_CMD cat > $HOME/.cursor/mcp.json <<'EOF'
{
  "mcpServers": {
    "obsidian": {
      "command": "node",
      "args": [
        "/home/pixel-peeper/Documents/secend-brain/node_modules/obsidian-mcp-server/dist/index.js"
      ],
      "env": {
        "OBSIDIAN_API_KEY": "'"$OBSIDIAN_API_KEY"'",
        "OBSIDIAN_BASE_URL": "'"$OBSIDIAN_BASE_URL"'",
        "OBSIDIAN_VERIFY_SSL": "false",
        "OBSIDIAN_ENABLE_CACHE": "true",
        "NODE_ENV": "production"
      }
    },
    "nixos": {
      "command": "nix",
      "args": [
        "run",
        "github:utensils/mcp-nixos",
        "--"
      ]
    },
    "GitKraken": {
      "command": "/home/pixel-peeper/.config/Cursor/User/globalStorage/eamodio.gitlens/gk",
      "type": "stdio",
      "name": "GitKraken",
      "args": [
        "mcp",
        "--host=cursor",
        "--source=gitlens",
        "--scheme=cursor"
      ],
      "env": {}
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/home/pixel-peeper/dotfiles"
      ]
    }
  }
}
EOF
  '';
}

