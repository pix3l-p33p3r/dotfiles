{ config, lib, pkgs, ... }:
let
  # KeePassXC SSH agent socket (defined in keepassxc.nix)
  sshAgentSocket = "${config.home.homeDirectory}/.local/share/keepassxc/ssh-agent";
  
  # Generate SSH config content (same as programs.ssh would generate, but as a regular file)
  sshConfigContent = ''
    # SSH configuration managed by Home Manager
    # Generated declaratively with proper permissions

    # KeePassXC agent only when its socket exists (otherwise use default $SSH_AUTH_SOCK / key file)
    Match exec "test -S ${sshAgentSocket}"
        IdentityAgent ${sshAgentSocket}

    # GitHub-specific configuration
    Host github.com
        Hostname ssh.github.com
        Port 443
        User git
        IdentityFile ~/.ssh/id_ed25519
        IdentitiesOnly yes
        ForwardAgent yes
    
    # 1337 School vogsphere configuration
    Host vogsphere-v2-bg.1337.ma
        Hostname vogsphere-v2-bg.1337.ma
        User git
        Port 22
        IdentityFile ~/.ssh/id_ed25519
        ForwardAgent yes
    
    # Default settings for all other hosts
    Host *
        ForwardAgent yes
        IdentityFile ~/.ssh/id_ed25519
        ServerAliveInterval 30
        ServerAliveCountMax 3
  '';

  # home.file would symlink into /nix/store; OpenSSH rejects that (wrong owner / perms).
  sshConfigFile = pkgs.writeText "hm-ssh-config" sshConfigContent;
in
{
  # Ensure .ssh directory has correct permissions
  home.activation.ensureSshDir = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    SSH_DIR="${config.home.homeDirectory}/.ssh"
    $DRY_RUN_CMD mkdir -p "$SSH_DIR"
    $DRY_RUN_CMD chmod 700 "$SSH_DIR" || true
  '';

  # Install a real ~/.ssh/config (mode 600, owned by you) on every activation
  home.activation.installSshConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD install -m 600 ${sshConfigFile} "${config.home.homeDirectory}/.ssh/config"
  '';

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

  # Backup existing SSH config if it exists and is not managed by us
  home.activation.backupSshConfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    SSH_CONFIG="${config.home.homeDirectory}/.ssh/config"
    SSH_BACKUP="${config.home.homeDirectory}/.ssh/config.pre-hm"
    
    # Only backup if it's a symlink (old Home Manager style) or doesn't match our content
    if [ -L "$SSH_CONFIG" ] || ([ -f "$SSH_CONFIG" ] && ! grep -q "SSH configuration managed by Home Manager" "$SSH_CONFIG" 2>/dev/null); then
      if [ ! -f "$SSH_BACKUP" ]; then
        echo "Backing up existing SSH config to $SSH_BACKUP"
        $DRY_RUN_CMD cp "$SSH_CONFIG" "$SSH_BACKUP" 2>/dev/null || true
      fi
      # Remove old config (symlink or old file) - Home Manager will create new one
      $DRY_RUN_CMD rm -f "$SSH_CONFIG" || true
    fi
  '';
}



