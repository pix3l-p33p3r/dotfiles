{ lib, ... }:

{
  services.clamav = {
    # ClamAV daemon (clamd) — required for on-demand and scheduled scanning
    daemon = {
      enable = true;
      settings = {
        # Exclude immutable/virtual paths — no malware lives there
        ExcludePath = [
          "^/nix/store"
          "^/proc"
          "^/sys"
          "^/run"
          "^/dev"
        ];

        # Alert on broken/encrypted archives (don't block, just flag)
        AlertBrokenExecutables = true;
        AlertEncryptedArchive  = true;
        AlertEncryptedDoc      = true;

        # Cap resource usage on a laptop
        MaxThreads        = 4;
        MaxQueue          = 200;
        ScanPE            = true;
        ScanELF           = true;
        ScanOLE2          = true;
        ScanPDF           = true;
        ScanHTML          = true;
        ScanArchive       = true;
        MaxFileSize       = "100M";  # Skip files larger than 100 MB
        MaxScanSize       = "400M";
        MaxRecursion      = 16;
        MaxFiles          = 10000;
      };
    };

    # freshclam — keeps virus definitions up to date
    updater = {
      enable   = true;
      frequency = 12;  # Check for updates twice daily
      settings = {
        Checks         = 12;
        # Mirror selection — official DB mirrors
        DatabaseMirror = [ "database.clamav.net" ];
      };
    };

    # clamonacc — on-access scanning (kernel fanotify hook)
    # Disabled: too CPU-intensive for a laptop and requires careful tuning.
    # Use the daily systemd scan below instead.
    fangfrisch.enable = false;
  };

  # Delay freshclam until DNS is ready — it queries current.cvd.clamav.net at
  # startup and fails with NXDOMAIN if systemd-resolved isn't up yet.
  systemd.services.clamav-freshclam = {
    after = [ "network-online.target" "nss-lookup.target" ];
    wants = [ "network-online.target" "nss-lookup.target" ];
  };

  # ───── Daily scheduled scan ─────
  # Scans home directory and /etc; results logged to journald.
  # Runs at 03:00 when the laptop is likely idle.
  systemd.services.clamav-scan = {
    description = "ClamAV daily home scan";
    wants       = [ "network-online.target" ];
    after       = [ "clamav-daemon.service" "network-online.target" ];
    requires    = [ "clamav-daemon.service" ];

    serviceConfig = {
      Type            = "oneshot";
      ExecStart       = "/run/current-system/sw/bin/clamdscan --fdpass --recursive --quiet /home /etc";
      Nice            = 19;      # lowest CPU priority
      IOSchedulingClass = "idle"; # lowest I/O priority
      User            = "root";
    };
  };

  systemd.timers.clamav-scan = {
    description     = "ClamAV daily home scan timer";
    wantedBy        = [ "timers.target" ];
    timerConfig = {
      OnCalendar    = "03:00";
      Persistent    = true;   # run on next boot if missed
      RandomizedDelaySec = "30m"; # avoid thundering-herd if multiple machines
    };
  };
}
