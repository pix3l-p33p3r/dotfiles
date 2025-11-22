{ config, lib, ... }:
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
      # GPG private key (optional - add to secrets/users/pixel-peeper.yaml under 'gpg.private_key' if needed)
      "gpg/private_key" = {
        path = "${config.home.homeDirectory}/.config/sops-secrets/gpg-private-key.asc";
        sopsFile = ../../secrets/users/pixel-peeper.yaml;
      };
      # SSH private key (declarative recovery - add to secrets/users/pixel-peeper.yaml under 'ssh.private_key')
      "ssh/private_key" = {
        path = "${config.home.homeDirectory}/.config/sops-secrets/ssh-private-key";
        sopsFile = ../../secrets/users/pixel-peeper.yaml;
      };
    };
  };

  # Ensure the age key used by both Home Manager and system-level sops-nix
  # exists locally. The private key itself lives outside git (copy it out of
  # KeePassXC when provisioning a new machine) but we still enforce sane
  # permissions here so rebuilds fail fast if the key is missing.
  home.activation.ensureAgeKey =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      AGE_KEY_FILE="${config.sops.age.keyFile}"
      AGE_KEY_DIR="$(dirname "$AGE_KEY_FILE")"

      $DRY_RUN_CMD mkdir -p "$AGE_KEY_DIR"

      if [ ! -s "$AGE_KEY_FILE" ]; then
        cat <<'EOF'
[opsec] Missing age key used for SOPS decryption.
Copy the existing key material from the KeePassXC entry
("Age private key") into $AGE_KEY_FILE before re-running the build.
EOF
        exit 1
      fi

      $DRY_RUN_CMD chmod 600 "$AGE_KEY_FILE"
    '';
}

