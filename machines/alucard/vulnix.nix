{ pkgs, ... }:

{
  # ───── Vulnix — NixOS-native CVE scanner ─────
  # Scans the current system closure against the NVD CVE database.  Works at
  # the Nix store level: parses derivation names+versions, cross-references
  # with NVD, and reports packages with known unpatched vulnerabilities.
  #
  # Why on top of trivy/grype: those scan container images / project
  # dependencies, not the running NixOS closure.  Vulnix understands NixOS
  # derivations natively (e.g., `python-3.13.7-vulnerable@CVE-2025-0123`).
  # Addresses Lynis PKGS-7398.
  environment.systemPackages = [ pkgs.vulnix ];

  # State directory for the cached NVD feed (re-downloaded weekly).
  systemd.tmpfiles.rules = [
    "d /var/lib/vulnix  0755 root root -"
    "d /var/log/vulnix  0755 root root -"
  ];

  # ── Weekly scan ──
  # Scans the running system's closure.  Output is JSON + human report;
  # the secscan helper reads the JSON for summary, the .log for details.
  systemd.services.vulnix-scan = {
    description = "Vulnix: scan the current NixOS closure for known CVEs";
    after    = [ "network-online.target" "nss-lookup.target" ];
    wants    = [ "network-online.target" "nss-lookup.target" ];
    wantedBy = [ ];   # timer-driven

    serviceConfig = {
      Type              = "oneshot";
      Nice              = 19;
      IOSchedulingClass = "idle";
      User              = "root";
      Environment = [
        "XDG_CACHE_HOME=/var/lib/vulnix"
        "HOME=/var/lib/vulnix"
      ];
      # vulnix exits 1 when CVEs are found, 2 when whitelisted; both are
      # successful runs from systemd's perspective.
      SuccessExitStatus = "0 1 2";
    };

    script = ''
      set -uo pipefail
      LOG=/var/log/vulnix/vulnix.log
      JSON=/var/log/vulnix/vulnix.json

      echo "vulnix-scan: scanning current system closure (this may take a few min)..."
      # --system: scan /run/current-system/sw closure
      # --json:   structured output for the secscan parser
      ${pkgs.vulnix}/bin/vulnix --system --json > "$JSON.tmp" 2>"$LOG"
      mv "$JSON.tmp" "$JSON"

      # Quick human summary into journal.  Python heredoc lives inside a
      # Nix multiline string, so we use double-quoted Python literals
      # throughout to avoid two-single-quote sequences that would close
      # the surrounding Nix string.
      echo "=== Vulnix summary ==="
      ${pkgs.python3Minimal}/bin/python3 - <<"PY"
import json
try:
    with open("/var/log/vulnix/vulnix.json") as f:
        data = json.load(f)
    items = data if isinstance(data, list) else []
    n = len(items)
    print(f"vulnix: {n} affected derivations")
    seen = 0
    for entry in items[:10]:
        name = entry.get("name") or entry.get("pname") or "?"
        cves = entry.get("affected_by") or entry.get("cves") or []
        if cves:
            head = ", ".join(cves[:3])
            tail = "..." if len(cves) > 3 else ""
            print(f"  - {name}: {len(cves)} CVE(s) -- {head}{tail}")
            seen += 1
    if n > seen:
        print(f"  ... and {n - seen} more (see /var/log/vulnix/vulnix.json)")
except Exception as e:
    print(f"vulnix: could not parse JSON output: {e}")
PY
    '';
  };

  systemd.timers.vulnix-scan = {
    description = "Vulnix weekly closure CVE scan";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar         = "Sun 06:00";
      Persistent         = true;
      RandomizedDelaySec = "1h";
    };
  };
}
