{ ... }:
{
  # ───── System-wide DNS-over-TLS via Mullvad ─────
  # Uses the "base" resolver: blocks ads, trackers, and malware.
  # Strict DoT — all queries are encrypted, no unencrypted fallback.
  services.resolved = {
    enable = true;
    dnssec = "false";
    dnsOverTls = "yes";
    domains = [ "~." ];
    dns = [
      "194.242.2.4#base.dns.mullvad.net"
      "2a07:e340::4#base.dns.mullvad.net"
    ];
    fallbackDns = [];
  };

  # Delegate DNS management to systemd-resolved instead of NetworkManager
  # writing /etc/resolv.conf directly.
  networking.networkmanager.dns = "systemd-resolved";
}
