{ config, pkgs, lib, ... }:
{
  # Enable GPG with declarative configuration
  programs.gpg = {
    enable = true;
    # Configure pinentry for secure passphrase entry
    # Use pinentry-curses for terminal, or pinentry-gtk/qt for GUI
    pinentryPackage = pkgs.pinentry-curses; # Change to pkgs.pinentry-gtk2 or pkgs.pinentry-qt if you prefer GUI
    settings = {
      # Standard GPG settings
      default-key = ""; # Will be determined from imported keys
      keyserver = "keys.openpgp.org";
      auto-key-retrieve = true;
      use-agent = true;
    };
  };

  # Import GPG private key from SOPS at activation time
  # Runs after secrets are decrypted (writeBoundary)
  home.activation.importGpgKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
    GPG_KEY_FILE="${config.sops.secrets."gpg/private_key".path}"
    
    if [ -f "$GPG_KEY_FILE" ]; then
      echo "Importing GPG private key from SOPS..."
      $DRY_RUN_CMD mkdir -p "$HOME/.gnupg"
      
      # Import the key if it exists
      $DRY_RUN_CMD ${pkgs.gnupg}/bin/gpg --batch --import "$GPG_KEY_FILE" 2>/dev/null || {
        # Key might already exist, which is fine
        echo "Note: GPG key may already be imported (this is normal)"
      }
      
      # Ensure proper permissions on GPG directory
      $DRY_RUN_CMD chmod 700 "$HOME/.gnupg" || true
      
      echo "GPG key import complete"
    else
      echo "Warning: GPG private key file not found at $GPG_KEY_FILE"
      echo "Add your GPG private key to secrets/users/pixel-peeper.yaml under 'gpg.private_key'"
    fi
  '';
}

