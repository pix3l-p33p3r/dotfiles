# Lokinet — INTENTIONALLY DISABLED
#
# Status (as of nixpkgs unstable @ flake.lock pin):
#   - pkgs.lokinet is marked `meta.broken = true` and refuses to evaluate
#   - upstream oxen-io/lokinet has been largely quiet since 2024
#
# Why we don't actually need it for Session:
#   Session-desktop performs its OWN onion routing through Loki Service
#   Nodes — it does not depend on a system Lokinet daemon. System Lokinet is
#   only required for resolving ".loki" URLs in browsers and arbitrary
#   client apps, which is not part of the current threat model.
#
# To re-enable when nixpkgs un-breaks the package:
#   1. Remove this file's stub status (delete the comment block, populate
#      the systemd.services.lokinet block, and uncomment the import in
#      machines/alucard/default.nix)
#   2. The original plan blueprint:
#        environment.systemPackages = [ pkgs.lokinet ];
#        systemd.services.lokinet = {
#          description = "Lokinet anonymous overlay network";
#          after = [ "network-online.target" ];
#          wants = [ "network-online.target" ];
#          wantedBy = [ ];   # on-demand only
#          serviceConfig = {
#            ExecStart        = "${pkgs.lokinet}/bin/lokinet";
#            Restart          = "on-failure";
#            DynamicUser      = true;
#            StateDirectory   = "lokinet";
#            AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
#            ProtectSystem    = "strict";
#            NoNewPrivileges  = true;
#            MemoryMax        = "256M";
#          };
#        };
{ ... }: { }
