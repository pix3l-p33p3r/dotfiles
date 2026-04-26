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

  # ───── Real-time scan of ~/Downloads ─────
  # inotifywait blocks reading kernel inotify events and pipes new file paths
  # to clamdscan, which socket-activates the daemon on first hit.  Detections
  # are surfaced via notify-send to the active Hyprland session.
  systemd.services.clamav-inotify-downloads = {
    description = "ClamAV real-time scan of ~/Downloads via inotify";
    after    = [ "clamav-daemon.socket" ];
    requires = [ "clamav-daemon.socket" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.inotify-tools pkgs.clamav pkgs.libnotify pkgs.coreutils ];

    serviceConfig = {
      Type              = "simple";
      User              = "root";
      Restart           = "on-failure";
      RestartSec        = "5s";
      Nice              = 19;
      IOSchedulingClass = "idle";

      # ── Hardening (was 9.6 UNSAFE) ──
      # The script only reads from ~/Downloads, talks to clamd over a
      # UNIX socket, and runs notify-send via DBus.  No mutation of
      # system state needed.
      NoNewPrivileges         = true;
      LockPersonality         = true;
      RestrictRealtime        = true;
      RestrictSUIDSGID        = true;
      ProtectClock            = true;
      ProtectKernelLogs       = true;
      ProtectControlGroups    = true;
      SystemCallArchitectures = "native";
      MemoryDenyWriteExecute  = true;
      PrivateMounts           = true;
      PrivateTmp              = true;
      ProtectKernelTunables   = true;
      ProtectKernelModules    = true;
      RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
      RestrictNamespaces      = true;
      # ProtectSystem=strict would block the script's tmp paths; full is
      # almost as good and lets clamdscan write its own per-scan temp.
      ProtectSystem           = "full";
    };

    script = ''
      DL="/home/pixel-peeper/Downloads"
      if [ ! -d "$DL" ]; then
        echo "clamav-inotify: $DL does not exist; sleeping forever"
        exec sleep infinity
      fi

      echo "clamav-inotify: watching $DL for new files..."
      inotifywait -m -r -q -e create -e moved_to --format '%w%f' "$DL" \
      | while read -r FILE; do
          # Skip directories — we only care about file completion events
          [ -f "$FILE" ] || continue
          # Wait briefly for the file to settle (large downloads still
          # writing).  inotify-wait fires on create, not on close-write,
          # because some tools (Firefox download tmp files) don't emit
          # close-write reliably.
          sleep 1
          RESULT=$(clamdscan --fdpass --no-summary "$FILE" 2>&1 || true)
          if echo "$RESULT" | grep -q "FOUND"; then
            BASENAME=$(basename "$FILE")
            DETAIL=$(echo "$RESULT" | grep "FOUND" | head -1)
            echo "clamav-inotify: THREAT in $FILE -- $DETAIL"
            # Best-effort notification — works when a Wayland session exists.
            sudo -u pixel-peeper \
              DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
              notify-send -u critical \
                "ClamAV: threat detected" \
                "$BASENAME\n$DETAIL" 2>/dev/null || true
          fi
        done
    '';
  };
}
