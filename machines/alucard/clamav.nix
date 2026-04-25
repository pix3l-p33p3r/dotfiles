{ lib, pkgs, ... }:

{
  services.clamav = {
    daemon = {
      enable = true;
      settings = {
        ExcludePath = [
          "^/nix/store"
          "^/proc"
          "^/sys"
          "^/run"
          "^/dev"
          "^/tmp"
          "^/home/.*/\\.cache"
          "^/home/.*/\\.npm"
          "^/home/.*/\\.cargo"
          "^/home/.*/\\.rustup"
          "^/home/.*/\\.local/share/Trash"
          "^/home/.*/\\.local/share/containers"
          "^/home/.*/\\.docker"
          "^/home/.*/node_modules"
        ];

        AlertBrokenExecutables = true;
        AlertEncryptedArchive  = true;
        AlertEncryptedDoc      = true;

        MaxThreads        = 2;
        MaxQueue          = 100;
        ScanPE            = true;
        ScanELF           = true;
        ScanOLE2          = true;
        ScanPDF           = true;
        ScanHTML          = true;
        ScanArchive       = true;
        MaxFileSize       = "100M";
        MaxScanSize       = "400M";
        MaxRecursion      = 16;
        MaxFiles          = 10000;
      };
    };

    updater = {
      enable    = true;
      frequency = 2;
      settings = {
        DatabaseMirror = [ "database.clamav.net" ];
      };
    };

    # Fangfrisch pulls third-party signature databases (Sanesecurity,
    # SecuriteInfo, MalwarePatrol) on top of the official ClamAV DB. Hugely
    # improves detection for phishing, PUPs, and emerging malware.
    fangfrisch = {
      enable = true;
      interval = "daily";
    };
  };

  # Defer freshclam from auto-starting on boot (saves ~1-3s of boot time and
  # network usage); the timer below still runs it on schedule.
  systemd.services.clamav-freshclam = {
    wantedBy = lib.mkForce [ ];
    after = [ "network-online.target" "nss-lookup.target" ];
    wants = [ "network-online.target" "nss-lookup.target" ];
  };

  # On-demand only — clamd loads ~1 GB of signatures into RAM; don't keep it
  # resident 24/7.  The scan timer starts it, and ExecStopPost shuts it down
  # once the scan finishes.
  systemd.services.clamav-daemon = {
    wantedBy = lib.mkForce [ ];
    after    = lib.mkForce [ "clamav-daemon.socket" ];
    wants    = lib.mkForce [ ];
    serviceConfig = {
      Nice              = 19;
      IOSchedulingClass = "idle";
      CPUQuota          = "100%";
      MemoryHigh        = "1G";
      MemoryMax         = "1200M";
    };
  };

  # ───── Daily scheduled scan ─────
  # Scans /home and /etc at 03:00; clamd is started before and stopped after
  # so the ~1 GB signature DB doesn't sit in RAM all day.
  systemd.services.clamav-scan = {
    description = "ClamAV daily home scan";
    wants       = [ "network-online.target" ];
    after       = [ "clamav-daemon.socket" "network-online.target" ];
    requires    = [ "clamav-daemon.socket" ];

    serviceConfig = {
      Type              = "oneshot";
      ExecStartPre      = "${pkgs.systemd}/bin/systemctl start clamav-daemon.service";
      ExecStart         = "/run/current-system/sw/bin/clamdscan --fdpass --quiet /home /etc";
      ExecStopPost      = "-${pkgs.systemd}/bin/systemctl stop clamav-daemon.service";
      Nice              = 19;
      IOSchedulingClass = "idle";
      CPUQuota          = "100%";
      User              = "root";
    };
  };

  systemd.timers.clamav-scan = {
    description = "ClamAV daily home scan timer";
    wantedBy    = [ "timers.target" ];
    timerConfig = {
      OnCalendar         = "03:00";
      Persistent         = true;
      RandomizedDelaySec = "30m";
    };
  };
}
