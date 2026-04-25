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

