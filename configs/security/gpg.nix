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

  # Configure GPG agent to use GUI pinentry for Wayland/Hyprland
  # Home Manager's programs.gpg doesn't expose agentSettings directly,
  # so we configure gpg-agent.conf manually
  # Use pinentry-gnome3 for GUI prompts (works with Wayland)
  home.packages = with pkgs; [
    pinentry-gnome3
  ];
  
  home.file.".gnupg/gpg-agent.conf" = {
    text = ''
      # GPG Agent configuration for pinentry
      # Use GUI pinentry for Wayland/Hyprland (works in lazygit, terminals, etc.)
      pinentry-program ${pkgs.pinentry-gnome3}/bin/pinentry-gnome3
      
      # Default cache timeout (in seconds)
      default-cache-ttl 600
      max-cache-ttl 7200
    '';
  };

  # Import GPG private key from SOPS at activation time (if configured)
  # Runs after secrets are decrypted (writeBoundary)
  home.activation.importGpgKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Check if GPG secret is configured in SOPS
    GPG_SECRET_PATH="${toString (config.sops.secrets."gpg/private_key" or { path = ""; }).path}"
    
    if [ -n "$GPG_SECRET_PATH" ] && [ -f "$GPG_SECRET_PATH" ]; then
      echo "Importing GPG private key from SOPS..."
      $DRY_RUN_CMD mkdir -p "$HOME/.gnupg"
      
      # Import the key if it exists
      $DRY_RUN_CMD ${pkgs.gnupg}/bin/gpg --batch --import "$GPG_SECRET_PATH" 2>/dev/null || {
        # Key might already exist, which is fine
        echo "Note: GPG key may already be imported (this is normal)"
      }
      
      # Ensure proper permissions on GPG directory
      $DRY_RUN_CMD chmod 700 "$HOME/.gnupg" || true
      
      echo "GPG key import complete"
    else
      # GPG key is optional - silently skip if not configured
      :
    fi
  '';
}

