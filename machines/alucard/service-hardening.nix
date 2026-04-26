{ lib, ... }:

# ───── systemd service hardening overrides ─────
#
# Reduces exposure scores reported by `systemd-analyze security` for the
# upstream NixOS service modules where we don't own the unit definition.
# Services we DO own (i2pd, clamav-inotify-downloads, hotspot, acs-vpn,
# tor, aide-*, lynis-audit, vulnix-scan) are hardened in their own
# defining files for locality.
#
# We use `lib.mkForce` selectively on directives that may collide with
# upstream defaults (e.g., dnsmasq already sets ProtectSystem=true; we
# tighten to "strict").  Non-conflicting directives are added as plain
# attributes and merged by NixOS.
#
# After rebuild, validate with:
#   sudo systemd-analyze security <service>
#
# Roll back if any service starts breaking — `systemctl status <svc>` and
# `journalctl -u <svc>` will surface what was blocked.

let
  # ── Always safe baseline ──
  base = {
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
  };

  # ── Filesystem-tight (for network daemons) ──
  fsTight = base // {
    ProtectHome            = true;
    PrivateTmp             = true;
    ProtectKernelTunables  = true;
    ProtectKernelModules   = true;
  };
in
{
  # ── NetworkManager (was 7.8 EXPOSED) ──
  systemd.services.NetworkManager.serviceConfig = fsTight;

  # ── NetworkManager-dispatcher (was 9.6 UNSAFE) ──
  # Runs arbitrary scripts (e.g., DNS-clear in dns.nix, strongswan plugin).
  systemd.services.NetworkManager-dispatcher.serviceConfig = base // {
    ProtectHome           = true;
    ProtectKernelModules  = true;
  };

  # ── dnsmasq (was 9.0 UNSAFE) ──
  # Upstream module sets ProtectSystem=true; tighten to "strict".  Skip
  # RestrictNamespaces because dnsmasq's chroot dance uses one.
  systemd.services.dnsmasq.serviceConfig = fsTight // {
    ProtectSystem           = lib.mkForce "strict";
    RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
    AmbientCapabilities     = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
    CapabilityBoundingSet   = [ "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
  };

  # ── strongswan (was 9.6 UNSAFE) ──
  # Needs /dev/net/tun, NET_ADMIN, and read access to /run/secrets/.
  systemd.services.strongswan.serviceConfig = fsTight // {
    CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_RAW" "CAP_NET_BIND_SERVICE" ];
  };

  # ── nscd (was 8.2 EXPOSED) ──
  # Upstream sets ProtectHome="read-only"; we tighten to true (no access).
  systemd.services.nscd.serviceConfig = fsTight // {
    ProtectHome = lib.mkForce true;
  };

  # ── clamav-daemon (was 7.8 EXPOSED) ──
  # Needs to read /home and elsewhere to scan; ProtectHome would defeat
  # the purpose.  Apply base + kernel restrictions only.
  systemd.services.clamav-daemon.serviceConfig = base // {
    ProtectKernelTunables = true;
    ProtectKernelModules  = true;
  };
}
