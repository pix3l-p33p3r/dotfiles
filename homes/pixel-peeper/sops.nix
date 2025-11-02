{ config, ... }:
{
  # SOPS secrets management for Home Manager
  sops = {
    # Use default age key location
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    
    # Point to the encrypted secrets file
    defaultSopsFile = ../../secrets/users/pixel-peeper.yaml;
    
    # Define secrets to decrypt
    secrets = {
      "obsidian/api_key" = {
        path = "${config.home.homeDirectory}/.config/sops-secrets/obsidian-api-key";
      };
      "obsidian/base_url" = {
        path = "${config.home.homeDirectory}/.config/sops-secrets/obsidian-base-url";
      };
    };
  };
}

