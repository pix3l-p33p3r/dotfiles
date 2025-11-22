{ config, lib, pkgs, ... }:
let
  # KeePassXC SSH agent socket (defined in keepassxc.nix)
  sshAgentSocket = "${config.home.homeDirectory}/.local/share/keepassxc/ssh-agent";
in
{
  programs.ssh = {
    enable = true;
    # Disable default config to have full control
    enableDefaultConfig = false;
    # Use KeePassXC SSH agent globally
    extraConfig = ''
      IdentityAgent ${sshAgentSocket}
    '';
    # Define host-specific configurations
    matchBlocks = {
      # GitHub-specific configuration
      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
        forwardAgent = true;
      };
      # 1337 School vogsphere configuration
      "vogsphere-v2-bg.1337.ma" = {
        hostname = "vogsphere-v2-bg.1337.ma";
        user = "git";
        port = 22;
        identityFile = "~/.ssh/id_ed25519";
        forwardAgent = true;
      };
      # Default settings for all other hosts
      "*" = {
        forwardAgent = true;
        identityFile = "~/.ssh/id_ed25519";
        serverAliveInterval = 30;
        serverAliveCountMax = 3;
      };
    };
  };

  # Restore SSH private key from SOPS (declarative recovery)
  home.activation.importSshKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
    SSH_SECRET_PATH="${toString (config.sops.secrets."ssh/private_key" or { path = ""; }).path}"
    SSH_KEY_DIR="${config.home.homeDirectory}/.ssh"
    SSH_KEY_FILE="$SSH_KEY_DIR/id_ed25519"
    
    if [ -n "$SSH_SECRET_PATH" ] && [ -f "$SSH_SECRET_PATH" ]; then
      echo "Restoring SSH private key from SOPS..."
      $DRY_RUN_CMD mkdir -p "$SSH_KEY_DIR"
      
      # Copy the key from SOPS to .ssh directory
      $DRY_RUN_CMD cp "$SSH_SECRET_PATH" "$SSH_KEY_FILE"
      
      # Set proper permissions (SSH requires strict permissions)
      $DRY_RUN_CMD chmod 600 "$SSH_KEY_FILE"
      $DRY_RUN_CMD chmod 700 "$SSH_KEY_DIR"
      
      # Ensure public key exists (generate if missing)
      if [ ! -f "$SSH_KEY_FILE.pub" ]; then
        echo "Generating SSH public key from private key..."
        $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -y -f "$SSH_KEY_FILE" > "$SSH_KEY_FILE.pub" 2>/dev/null || true
      fi
      
      echo "SSH key restored successfully"
    else
      # SSH key is optional - silently skip if not configured
      :
    fi
  '';

  # Backup and remove existing SSH config (Home Manager will create new one)
  home.activation.backupSshConfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    SSH_CONFIG="${config.home.homeDirectory}/.ssh/config"
    SSH_BACKUP="${config.home.homeDirectory}/.ssh/config.pre-keepassxc"
    if [ -f "$SSH_CONFIG" ]; then
      if [ ! -f "$SSH_BACKUP" ]; then
        echo "Backing up existing SSH config to $SSH_BACKUP"
        $DRY_RUN_CMD cp "$SSH_CONFIG" "$SSH_BACKUP" || true
      fi
      echo "Removing old SSH config to allow Home Manager to manage it"
      $DRY_RUN_CMD rm -f "$SSH_CONFIG" || true
    fi
  '';
}



