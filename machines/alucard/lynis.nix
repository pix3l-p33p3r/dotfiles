{ pkgs, ... }:

{
  # ───── Lynis — security auditing tool ─────
  # Comprehensive system audit: file permissions, service hardening, kernel
  # parameters, suspicious binaries, malware-like artifacts (cron persistence,
  # .ssh tampering, hidden directories), CIS benchmark coverage.
  #
  # Complements AIDE: AIDE detects WHAT changed, Lynis evaluates WHETHER the
  # current state is hardened.  Together they cover both intrusion detection
  # and configuration drift.
  environment.systemPackages = [ pkgs.lynis ];

  # Storage for Lynis state + reports.
  systemd.tmpfiles.rules = [
    "d /var/log/lynis  0700 root root -"
    "d /var/lib/lynis  0700 root root -"
  ];

  # ── Weekly audit run ──
  # Outputs to journal (full report) + /var/log/lynis/lynis.log (long-form).
  # `--no-colors` and `--quiet` make journal output readable; the log file
  # retains the full detailed report for later review with `lynis show report`.
  systemd.services.lynis-audit = {
    description = "Lynis system security audit";
    after    = [ "local-fs.target" ];
    wantedBy = [ ];   # timer-driven
    serviceConfig = {
      Type              = "oneshot";
      Nice              = 19;
      IOSchedulingClass = "idle";
      User              = "root";
      Environment = [
        "LYNIS_DATA_DIR=/var/lib/lynis"
        "HOME=/var/lib/lynis"
      ];
      # Lynis uses non-zero exit codes to signal warnings/suggestions.
      SuccessExitStatus = "0 1 2 3 4 5";
    };
    script = ''
      ${pkgs.lynis}/bin/lynis audit system \
        --no-colors \
        --quiet \
        --auditor "alucard-systemd" \
        --logfile /var/log/lynis/lynis.log \
        --report-file /var/log/lynis/report.dat
      # Surface the hardening index + warnings count to journal for at-a-glance
      # status (long-form report stays in /var/log/lynis).
      echo "=== Lynis summary ==="
      grep -E '^(hardening_index|warning|suggestion)=' /var/log/lynis/report.dat | head -50 || true
    '';
  };

  systemd.timers.lynis-audit = {
    description = "Lynis weekly security audit";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar         = "Sun 05:00";
      Persistent         = true;
      RandomizedDelaySec = "1h";
    };
  };
}
