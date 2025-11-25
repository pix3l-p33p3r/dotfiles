{ lib, ... }:
{
  # Declarative Cursor AI Editor configuration
  # The One True Way™ - managed by Home Manager
  
  # Generate mcp.json at activation time (after secrets are decrypted)
  home.activation.generateCursorMcpConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $HOME/.cursor
    
    # Generate mcp.json (Obsidian integration removed per request)
    $DRY_RUN_CMD cat > $HOME/.cursor/mcp.json <<'EOF'
{
  "mcpServers": {
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

