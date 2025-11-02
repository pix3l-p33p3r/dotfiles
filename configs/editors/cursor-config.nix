{ config, pkgs, lib, ... }:
let
  # Read secrets from SOPS-decrypted files
  obsidianApiKey = lib.strings.removeSuffix "\n" (builtins.readFile config.sops.secrets."obsidian/api_key".path);
  obsidianBaseUrl = lib.strings.removeSuffix "\n" (builtins.readFile config.sops.secrets."obsidian/base_url".path);
in
{
  # Declarative Cursor AI Editor configuration
  # The One True Way™ - managed by Home Manager
  # Secrets managed with SOPS + Age encryption
  
  home.file.".cursor/mcp.json" = {
    text = builtins.toJSON {
      mcpServers = {
        # Obsidian MCP - Your second brain integration (with encrypted API key)
        obsidian = {
          command = "node";
          args = [
            "/home/pixel-peeper/Documents/secend-brain/node_modules/obsidian-mcp-server/dist/index.js"
          ];
          env = {
            OBSIDIAN_API_KEY = obsidianApiKey;
            OBSIDIAN_BASE_URL = obsidianBaseUrl;
            OBSIDIAN_VERIFY_SSL = "false";
            OBSIDIAN_ENABLE_CACHE = "true";
            NODE_ENV = "production";
          };
        };
        
        # NixOS MCP - The enlightened way
        nixos = {
          command = "nix";
          args = [
            "run"
            "github:utensils/mcp-nixos"
            "--"
          ];
        };
        
        # GitKraken MCP - Git operations
        GitKraken = {
          command = "/home/pixel-peeper/.config/Cursor/User/globalStorage/eamodio.gitlens/gk";
          type = "stdio";
          name = "GitKraken";
          args = [
            "mcp"
            "--host=cursor"
            "--source=gitlens"
            "--scheme=cursor"
          ];
          env = {};
        };
        
        # Filesystem MCP - Dotfiles access
        filesystem = {
          command = "npx";
          args = [
            "-y"
            "@modelcontextprotocol/server-filesystem"
            "/home/pixel-peeper/dotfiles"
          ];
        };
      };
    };
  };
}

