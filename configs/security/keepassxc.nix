{ lib, config, ... }:
{
  # Start a real ssh-agent as a systemd user service.
  # KeePassXC's SSH Agent integration connects to this socket and injects
  # stored keys when the database is unlocked.
  services.ssh-agent.enable = true;

  # Export the socket path to shell sessions and systemd user services.
  # $XDG_RUNTIME_DIR expands correctly in shell init files.
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";

  # Also set it in the systemd user environment so KeePassXC (which is
  # typically launched via systemd/DBUS) can see it.
  systemd.user.sessionVariables.SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";

  home.activation.ensureKeePassSocketDir =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.local/share/keepassxc"
    '';
}
