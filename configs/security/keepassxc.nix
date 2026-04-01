{ config, lib, ... }:
let
  sshAgentSocket = "${config.home.homeDirectory}/.local/share/keepassxc/ssh-agent";
in
{
  # KeePassXC owns the SSH agent — SSH_AUTH_SOCK points to its socket.
  # AddKeysToAgent in ssh.nix caches the key in-session once KeePassXC unlocks it.
  home.sessionVariables.SSH_AUTH_SOCK = sshAgentSocket;

  home.activation.ensureKeePassSocketDir =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.local/share/keepassxc"
    '';
}
