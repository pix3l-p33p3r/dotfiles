{ config, lib, pkgs, ... }:
let
  hardeningCiphers = [
    "chacha20-poly1305@openssh.com"
    "aes256-gcm@openssh.com"
    "aes128-gcm@openssh.com"
    "aes256-ctr"
    "aes192-ctr"
    "aes128-ctr"
  ];

  hardeningMacs = [
    "hmac-sha2-512-etm@openssh.com"
    "hmac-sha2-256-etm@openssh.com"
    "umac-128-etm@openssh.com"
  ];

  hardeningKex = [
    "sntrup761x25519-sha512@openssh.com"
    "curve25519-sha256"
    "curve25519-sha256@libssh.org"
    "ecdh-sha2-nistp521"
    "ecdh-sha2-nistp384"
    "ecdh-sha2-nistp256"
  ];
in
{
  # ───── Security & PAM ─────
  security.pam.services.hyprlock = {};

  # Prevent gnome-keyring's PAM module from injecting SSH_AUTH_SOCK=/run/user/*/gcr/ssh
  # at login — KeePassXC owns the SSH agent socket instead.
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # ── Password strength enforcement via pam_pwquality ──
  # Triggers when running `passwd`.  Single-user laptop, so this only
  # matters at password-change time — but addresses Lynis AUTH-9262.
  # Defaults: minlen=12, at least 1 of each class (upper/lower/digit/special).
  security.pam.services.passwd.rules.password.pwquality = {
    control    = "required";
    modulePath = "${pkgs.libpwquality.lib}/lib/security/pam_pwquality.so";
    order      = 11000;  # before unix (~12000) so quality check happens first
    args = [
      "retry=3"
      "minlen=12"
      "difok=3"           # at least 3 chars must differ from old password
      "ucredit=-1"        # at least 1 uppercase
      "lcredit=-1"        # at least 1 lowercase
      "dcredit=-1"        # at least 1 digit
      "ocredit=-1"        # at least 1 special char
      "enforce_for_root"
    ];
  };

  # ───── OpenSSH hardening ─────
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    # Bind to loopback only — SSH is used for local tunnels / Cursor remote
    # forwarding, never for incoming connections from other hosts. This makes
    # the campus network unable to even reach the SSH port.
    listenAddresses = [
      { addr = "127.0.0.1"; port = 22; }
      { addr = "::1";       port = 22; }
    ];
    openFirewall = false;
    settings = {
      LogLevel = "VERBOSE";
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      ChallengeResponseAuthentication = false;
      AuthenticationMethods = "publickey";
      AllowAgentForwarding = "yes";
      X11Forwarding = false;
      AllowTcpForwarding = "no";
      LoginGraceTime = "30s";
      MaxAuthTries = 3;
      MaxSessions = 2;
      ClientAliveInterval = 120;
      ClientAliveCountMax = 2;
      Ciphers = hardeningCiphers;
      Macs = hardeningMacs;
      KexAlgorithms = hardeningKex;
    };
  };

  # ───── fail2ban ─────
  # Belt-and-suspenders for SSH (already loopback-only) and any other future
  # listening services — bans IPs after repeated auth failures.
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime  = "1h";
    bantime-increment = {
      enable     = true;
      multipliers = "1 2 4 8 16 32 64";
      maxtime    = "168h";  # one week max
      overalljails = true;
    };
  };

  # ───── AppArmor ─────
  security.apparmor = {
    enable = true;
    # Don't kill unconfined processes — enforce only where profiles exist
    killUnconfinedConfinables = false;
    # Community profiles for common system utilities
    packages = [ pkgs.apparmor-profiles ];
  };

  # ───── DCONF & GSETTINGS ─────
  programs.dconf.enable = true;
  services.dbus.enable = true;
}

