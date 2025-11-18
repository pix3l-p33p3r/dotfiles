{ config, lib, ... }:
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

  # ───── OpenSSH hardening ─────
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
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

  # ───── DCONF & GSETTINGS ─────
  programs.dconf.enable = true;
  services.dbus.enable = true;
}

