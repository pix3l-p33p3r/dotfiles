{ lib, config, ... }:
{
  # Start a real ssh-agent as a systemd user service.
  # KeePassXC's SSH Agent integration connects to this socket and injects
  # stored keys when the database is unlocked.
  services.ssh-agent.enable = true;

  # services.ssh-agent sets SSH_AUTH_SOCK correctly in shell sessions via
  # home.sessionVariables. We only need to propagate the path into the systemd
  # user environment so KeePassXC (launched via D-Bus activation) can see it.
  # %t is the systemd specifier for $XDG_RUNTIME_DIR (/run/user/<uid>).
  systemd.user.sessionVariables.SSH_AUTH_SOCK = "%t/ssh-agent";

  home.activation.ensureKeePassSocketDir =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.local/share/keepassxc"
    '';
}
