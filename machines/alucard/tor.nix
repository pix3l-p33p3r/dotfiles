{ pkgs, ... }:

{
  # ───── Tor (client-only) ─────
  # SOCKS5 proxy at 127.0.0.1:9050 — usage:
  #   torsocks <cmd>                      # transparently torify any command
  #   curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org
  #   (browsers): set SOCKS5 host=127.0.0.1 port=9050, "Use proxy DNS" enabled
  #
  # DNS resolver at 127.0.0.1:9053 — usage:
  #   dig @127.0.0.1 -p 9053 example.com  # anonymous DNS lookup via Tor
  #
  # Tor is outbound-only on the loopback. No firewall changes needed.
  services.tor = {
    enable = true;
    client = {
      enable = true;
      dns.enable = true;
    };
    torsocks.enable = true;
    settings = {
      # Reject SOCKS connections that include a non-anonymous local IP in the
      # request (catches misconfigured apps that would leak the real IP).
      SafeSocks = true;
      # Auto-detect plaintext credentials being torified by accident.
      TestSocks = true;
      # Don't write Tor state to disk unless necessary (reduces forensic trace).
      AvoidDiskWrites = true;
    };
  };

  # nyx: TUI Tor circuit/bandwidth monitor (`nyx` to launch).
  environment.systemPackages = [ pkgs.nyx ];
}
