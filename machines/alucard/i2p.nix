{ ... }:

{
  # ───── I2P (i2pd C++ implementation) ─────
  # Anonymous overlay network. Sites end in `.i2p` (e.g., http://stats.i2p).
  # Used by:
  #   - LibreWolf "i2p" profile (HTTP proxy 127.0.0.1:4444)
  #   - any SOCKS5 client (127.0.0.1:4447) for non-HTTP I2P services
  #   - web console at http://127.0.0.1:7070 for tunnel monitoring / IPNS
  services.i2pd = {
    enable = true;

    # Modest contribution to the network (KBps).  Doubles as our own throughput
    # ceiling — bumping this gives faster .i2p loads but more battery / data.
    bandwidth = 256;

    # IPv4-only: campus / hotspot / mobile networks rarely route IPv6.  Saves
    # ~10s of peer-discovery timeout on networks without global IPv6.
    enableIPv4 = true;
    enableIPv6 = false;

    proto = {
      # Web console for tunnel monitoring / address book / Java I2P UI.
      # Loopback only — never expose to the network.
      http = {
        enable  = true;
        address = "127.0.0.1";
        port    = 7070;
      };

      # HTTP proxy for browsing .i2p sites.
      httpProxy = {
        enable  = true;
        address = "127.0.0.1";
        port    = 4444;
      };

      # SOCKS proxy for non-HTTP I2P services (irc, etc.).
      socksProxy = {
        enable  = true;
        address = "127.0.0.1";
        port    = 4447;
      };
    };
  };

  # ── Hardening (was 9.2 UNSAFE) ──
  # i2pd is a self-contained network daemon.  The upstream NixOS module
  # uses /var/lib/i2pd for its pidfile + state but doesn't declare a
  # StateDirectory, so under ProtectSystem=strict we must whitelist it
  # explicitly via ReadWritePaths.
  systemd.services.i2pd.serviceConfig = {
    NoNewPrivileges         = true;
    LockPersonality         = true;
    RestrictRealtime        = true;
    RestrictSUIDSGID        = true;
    ProtectClock            = true;
    ProtectKernelLogs       = true;
    ProtectControlGroups    = true;
    SystemCallArchitectures = "native";
    MemoryDenyWriteExecute  = true;
    PrivateMounts           = true;
    PrivateTmp              = true;
    ProtectHome             = true;
    ProtectKernelTunables   = true;
    ProtectKernelModules    = true;
    ProtectSystem           = "strict";
    ReadWritePaths          = [ "/var/lib/i2pd" ];
    RestrictNamespaces      = true;
    RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
  };
}
