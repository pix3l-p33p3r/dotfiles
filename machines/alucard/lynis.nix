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

  # ── Custom Lynis profile ──
  # Suppresses checks that are false positives on a NixOS / systemd setup
  # (legacy paths Lynis grep's for don't exist; the underlying capability
  # is provided differently).  Each skip is annotated with WHY it's safe.
  environment.etc."lynis/custom.prf".text = ''
    # ── False positives on NixOS / systemd ──
    # Network protocol modules — already blacklisted in machines/alucard/boot.nix
    # so they cannot be loaded; Lynis only checks if the module is *available*.
    # NOTE: a single skip-test=<id> covers ALL instances of that test
    # (Lynis aggregates by test ID, not by per-protocol parameter).
    skip-test=NETW-3200

    # nftables firewall is enabled in machines/alucard/firewall.nix; Lynis
    # only checks for /etc/iptables which doesn't exist with nftables.
    skip-test=FIRE-4590

    # systemd-resolved + systemd-timesyncd handle DNS + NTP correctly;
    # Lynis is looking for legacy /etc/resolv.conf static config and ntpd.
    skip-test=NAME-4028
    skip-test=NAME-4404
    skip-test=TIME-3104

    # systemd-journald replaced syslog (see also LOGG-2138 warning); these
    # checks predate the systemd era.
    skip-test=LOGG-2130
    skip-test=LOGG-2138

    # AIDE is installed in machines/alucard/aide.nix; Lynis can't see it on
    # NixOS paths because aide lives in /run/current-system/sw/bin not /usr.
    skip-test=FINT-4350

    # ClamAV is on-demand (clamav.nix) so clamd isn't always running for
    # Lynis to detect; periodic scan timer covers this requirement.
    skip-test=HRDN-7230

    # NixOS itself is the system-management automation tool.
    skip-test=TOOL-5002

    # ── Personal-laptop trade-offs (not security gaps in this threat model) ──
    # Forced password aging is anti-pattern per NIST 800-63B (2017+).
    skip-test=AUTH-9286

    # Single-user laptop with LUKS — bumping shadow rounds doesn't add
    # meaningful security against the realistic attacker model.
    skip-test=AUTH-9230

    # /home is on a dedicated LUKS volume; /tmp is tmpfs (boot.tmp.useTmpfs).
    # /var separation would require a reinstall and isn't worth the disruption.
    skip-test=FILE-6310

    # Personal laptop; no shared-system legal banner is meaningful.
    skip-test=BANN-7126

    # Process accounting + sysstat add forensics depth at I/O cost — defer.
    skip-test=ACCT-9622
    skip-test=ACCT-9626

    # Disabling USB storage breaks legitimate use (thumb drives, backups).
    skip-test=USB-1000
  '';

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
      # Lynis auto-loads /etc/lynis/custom.prf at the standard location and
      # merges it with default.prf.  Passing --profile would *replace* the
      # default and silently drop most of Lynis's behavior.  See:
      # https://cisofy.com/documentation/lynis/configuration/
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

  # ───── logrotate ─────
  # journald handles its own rotation, but anything else writing to /var/log
  # (Lynis reports, tlp logs, ClamAV, etc.) needs explicit rotation.  Default
  # NixOS profile rotates weekly with 4 copies kept.  Addresses Lynis LOGG-2146.
  services.logrotate.enable = true;
}
