{ config, pkgs, lib, ... }:
{
  # Enable GPG with declarative configuration
  programs.gpg = {
    enable = true;
    settings = {
      # Standard GPG settings
      # default-key is not set yet - will be set after key is generated
      keyserver = "keys.openpgp.org";
      auto-key-retrieve = true;
      use-agent = true;
    };
  };

  # Configure GPG agent to use pinentry
  # Home Manager's programs.gpg doesn't expose agentSettings directly,
  # so we configure gpg-agent.conf manually
  home.file.".gnupg/gpg-agent.conf" = {
    text = ''
      # GPG Agent configuration for pinentry
      pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
      
      # Default cache timeout (in seconds)
      default-cache-ttl 600
      max-cache-ttl 7200
    '';
  };

  # Import GPG private key from SOPS at activation time
  # Runs after secrets are decrypted (writeBoundary)
  # Temporarily disabled until GPG key is generated and added to SOPS
  # Uncomment after adding gpg/private_key to secrets/users/pixel-peeper.yaml
  # home.activation.importGpgKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #   GPG_KEY_FILE="${config.sops.secrets."gpg/private_key".path}"
  #   
  #   if [ -f "$GPG_KEY_FILE" ]; then
  #     echo "Importing GPG private key from SOPS..."
  #     $DRY_RUN_CMD mkdir -p "$HOME/.gnupg"
  #     
  #     # Import the key if it exists
  #     $DRY_RUN_CMD ${pkgs.gnupg}/bin/gpg --batch --import "$GPG_KEY_FILE" 2>/dev/null || {
  #       # Key might already exist, which is fine
  #       echo "Note: GPG key may already be imported (this is normal)"
  #     }
  #     
  #     # Ensure proper permissions on GPG directory
  #     $DRY_RUN_CMD chmod 700 "$HOME/.gnupg" || true
  #     
  #     echo "GPG key import complete"
  #   else
  #     echo "Warning: GPG private key file not found at $GPG_KEY_FILE"
  #     echo "Add your GPG private key to secrets/users/pixel-peeper.yaml under 'gpg.private_key'"
  #   fi
  # '';
}

