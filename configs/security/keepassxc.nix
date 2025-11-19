{ config, lib, pkgs, ... }:
let
  sshAgentSocket = "${config.home.homeDirectory}/.local/share/keepassxc/ssh-agent";
in
{
  programs.ssh = {
    enable = true;
    # Backup existing SSH config if it exists
    extraConfig = ''
      IdentityAgent ${sshAgentSocket}

      Host *
        ForwardAgent yes
        IdentityFile ~/.ssh/id_ed25519
        PreferredAuthentications publickey
      ServerAliveInterval 30
      ServerAliveCountMax 3
    '';
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

  home.sessionVariables.SSH_AUTH_SOCK = sshAgentSocket;

  xdg.configFile."environment.d/20-keepassxc-ssh-agent.conf".text = ''
    SSH_AUTH_SOCK=${sshAgentSocket}
  '';

  xdg.configFile."autostart/keepassxc.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=KeePassXC
    Comment=Unlock KeePassXC for OTP/secrets and expose the SSH agent socket
    Exec=${pkgs.keepassxc}/bin/keepassxc --lock
    X-GNOME-Autostart-enabled=true
  '';

  # Ensure KeepassXC has a place to drop its SSH agent socket and leave a
  # reminder documenting what belongs there (the actual database lives outside git).
  home.activation.ensureKeePassSocketDir =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.local/share/keepassxc"
    '';

  xdg.configFile."keepassxc/README-opsec.md".text = ''
    # KeePassXC OpSec Notes

    - KeePassXC owns interactive secrets (master password, OTP seeds, SSH/LUKS passphrases).
    - Enable the SSH Agent integration inside KeePassXC Preferences → SSH Agent.
    - Set the socket path to ${sshAgentSocket} so the desktop session reuses the agent.
    - Store the age private key string and recovery passphrases inside this database.
    - When rotating age/GPG keys, export temporary ASCII armor files, re-encrypt with SOPS,
      and then delete the temporary exports after verifying new entries.
  '';
}


