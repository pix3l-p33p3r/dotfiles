{ config, lib, ... }:
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



