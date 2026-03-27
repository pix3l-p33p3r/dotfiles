{ ... }:
{
  # ───── System-wide DNS-over-TLS via Mullvad ─────
  # Uses the "base" resolver: blocks ads, trackers, and malware.
  # Strict DoT — all queries are encrypted, no unencrypted fallback.
  #
  # DNS servers live under settings.Resolve (nixpkgs removed the old
  # services.resolved.dns top-level option).
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [
        "194.242.2.4#base.dns.mullvad.net"
        "2a07:e340::4#base.dns.mullvad.net"
      ];
      DNSOverTLS = "yes";
      DNSSEC = "no";
      Domains = [ "~." ];
      FallbackDNS = [ ];
    };
  };

  # NixOS also sets this when resolved is enabled; kept explicit for clarity.
  networking.networkmanager.dns = "systemd-resolved";
}
