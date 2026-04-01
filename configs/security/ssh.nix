{ config, lib, pkgs, ... }:
let
  # home.file symlinks into /nix/store; OpenSSH rejects that (wrong perms/owner).
  sshConfig = pkgs.writeText "hm-ssh-config" ''
    # Managed by Home Manager — do not edit directly

    Host github.com
        Hostname ssh.github.com
        Port 443
        User git
        IdentityFile ~/.ssh/id_ed25519
        IdentitiesOnly yes
        ForwardAgent yes

    Host vogsphere-v2-bg.1337.ma
        Hostname vogsphere-v2-bg.1337.ma
        User git
        Port 22
        IdentityFile ~/.ssh/id_ed25519
        ForwardAgent yes

    Host *
        ForwardAgent yes
        IdentityFile ~/.ssh/id_ed25519
        AddKeysToAgent yes
        ServerAliveInterval 30
        ServerAliveCountMax 3
  '';
in
{
  home.activation.ensureSshDir = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.ssh"
    $DRY_RUN_CMD chmod 700 "${config.home.homeDirectory}/.ssh" || true
  '';

  home.activation.installSshConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD install -m 600 ${sshConfig} "${config.home.homeDirectory}/.ssh/config"
  '';

  home.activation.importSshKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    SSH_SECRET_PATH="${toString (config.sops.secrets."ssh/private_key" or { path = ""; }).path}"
    SSH_KEY="${config.home.homeDirectory}/.ssh/id_ed25519"
    if [ -n "$SSH_SECRET_PATH" ] && [ -f "$SSH_SECRET_PATH" ]; then
      $DRY_RUN_CMD install -m 600 "$SSH_SECRET_PATH" "$SSH_KEY"
      if [ ! -f "$SSH_KEY.pub" ]; then
        $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -y -f "$SSH_KEY" > "$SSH_KEY.pub" 2>/dev/null || true
      fi
    fi
  '';
}
