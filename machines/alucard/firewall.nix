{ lib, ... }:

{
  # ───── nftables backend ─────
  # Replaces iptables with nftables; iptables-nft wrappers keep Docker working.
  networking.nftables.enable = true;

  # ───── Firewall ─────
  networking.firewall = {
    enable = true;

    # Drop (stealth) rather than reject with ICMP unreachable
    rejectPackets = false;

    # SSH is opened automatically by services.openssh; listed here for clarity.
    # IPsec ports (500, 4500) and ESP are opened in vpn.nix.
    allowedTCPPorts = [ 22 ];
  };

  # ───── Network hardening sysctls ─────
  boot.kernel.sysctl = {
    # Ignore ICMP redirects (prevent routing table poisoning)
    "net.ipv4.conf.all.accept_redirects"     = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects"     = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;

    # Don't send ICMP redirects (not a router)
    "net.ipv4.conf.all.send_redirects"     = 0;
    "net.ipv4.conf.default.send_redirects" = 0;

    # Reverse-path filter: loose mode (2) catches spoofed addresses while
    # remaining compatible with Docker/libvirt asymmetric routing
    "net.ipv4.conf.all.rp_filter"     = 2;
    "net.ipv4.conf.default.rp_filter" = 2;

    # SYN flood protection
    "net.ipv4.tcp_syncookies" = 1;

    # Ignore ICMP broadcast pings
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;

    # Ignore bogus ICMP error responses
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

    # Don't accept IPv6 router advertisements (not a router, use NetworkManager)
    "net.ipv6.conf.all.accept_ra"     = 0;
    "net.ipv6.conf.default.accept_ra" = 0;
  };
}
