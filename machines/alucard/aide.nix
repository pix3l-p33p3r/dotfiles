{ config, pkgs, lib, ... }:

{
  # ───── AIDE — Advanced Intrusion Detection Environment ─────
  # Cryptographic hash database of system binaries / config / boot files.
  # Detects ANY tampering (rootkit injection, persistence implants, modified
  # SUID binaries, /etc backdoors) by comparing against a baseline database.
  #
  # Workflow:
  #   1. First boot:  systemctl start aide-init   (creates /var/lib/aide/aide.db)
  #   2. Every day:   aide-check.timer compares against the baseline
  #   3. After legit system change (e.g. nrs):  systemctl start aide-init
  #      to refresh the baseline so we don't get false positives.
  environment.systemPackages = [ pkgs.aide ];

  # AIDE configuration — what to hash, what to ignore.
  # Most of the system is in /nix/store (immutable, content-addressed) so we
  # don't need to hash store paths themselves; we just check that the symlinks
  # /run/current-system, /etc, /boot etc. resolve to the expected store paths.
  environment.etc."aide.conf".text = ''
    # Database paths
    database_in    = file:/var/lib/aide/aide.db
    database_out   = file:/var/lib/aide/aide.db.new
    database_new   = file:/var/lib/aide/aide.db.new

    # Report style
    # gzip_dbout disabled so the on-disk filenames in `database_in` /
    # `database_out` match exactly (otherwise AIDE writes aide.db.new.gz
    # but our paths don't have the .gz suffix and reads fail).
    gzip_dbout     = no
    report_url     = stdout
    # AIDE 0.18+ replaced the legacy `verbose = N` directive with
    # `report_level=`.  `changed_attributes` shows which attribute differs
    # for each modified entry — a good middle ground between minimal noise
    # and full attribute dumps.
    report_level   = changed_attributes

    # ── Rule definitions ──
    # FullCheck = perm + owner + group + ftype + size + ctime + mtime + sha256
    FullCheck   = p+u+g+ftype+s+c+m+sha256
    # PermsOnly  = catches permission/ownership changes only (for /etc which
    # systemd reloads can touch)
    PermsOnly   = p+u+g
    # Existence = path must exist; ignore content (Nix store paths are
    # immutable — hashing them is redundant and slow)
    Existence   = p+ftype

    # ── Watched paths ──
    # System binaries (PATH on a NixOS system points here via env links)
    /run/current-system/sw/bin       FullCheck
    /run/current-system/sw/sbin      FullCheck

    # Boot — kernel + initrd + EFI
    /boot                            FullCheck

    # Persistent system config
    /etc                             FullCheck
    !/etc/mtab
    !/etc/resolv\.conf
    !/etc/machine-id
    !/etc/adjtime
    !/etc/.updated
    !/etc/.pwd\.lock
    !/etc/ssh/ssh_host_.*

    # User shell environment
    /root                            FullCheck
    !/root/.bash_history
    !/root/.cache
    !/root/.local/share

    # Nix store: existence-only (paths are immutable, content-addressed)
    /nix/store                       Existence

    # Systemd unit files — directories often, files less so
    /etc/systemd                     FullCheck

    # Skip volatile / runtime trees entirely
    !/var/log
    !/var/cache
    !/var/lib/aide
    !/var/lib/systemd
    !/var/lib/docker
    !/var/lib/libvirt
    !/var/lib/upower
    !/var/spool
    !/var/tmp
  '';

  # Storage directory for the AIDE database.
  systemd.tmpfiles.rules = [
    "d /var/lib/aide 0700 root root -"
  ];

  # ── Initialization service: run once to create the baseline ──
  # Idempotent — exits early if the DB already exists.
  systemd.services.aide-init = {
    description = "AIDE database initialization (creates /var/lib/aide/aide.db)";
    after    = [ "local-fs.target" ];
    wants    = [ "local-fs.target" ];
    wantedBy = [ ];   # manual: `systemctl start aide-init`
    serviceConfig = {
      Type              = "oneshot";
      Nice              = 19;
      IOSchedulingClass = "idle";
      User              = "root";
    };
    script = ''
      set -eu
      if [ -f /var/lib/aide/aide.db ]; then
        echo "aide-init: /var/lib/aide/aide.db already exists; refreshing baseline..."
      else
        echo "aide-init: creating initial AIDE baseline (this can take 5-15 min)..."
      fi
      ${pkgs.aide}/bin/aide --init --config=/etc/aide.conf
      mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
      echo "aide-init: baseline ready at /var/lib/aide/aide.db"
    '';
  };

  # ── Daily integrity check ──
  systemd.services.aide-check = {
    description = "AIDE daily integrity check";
    after    = [ "local-fs.target" ];
    wants    = [ "local-fs.target" ];
    wantedBy = [ ];   # timer-driven
    serviceConfig = {
      Type              = "oneshot";
      Nice              = 19;
      IOSchedulingClass = "idle";
      User              = "root";
      # Don't fail systemd unit on file changes (exit code 1-7) — log and move on.
      SuccessExitStatus = "0 1 2 3 4 5 6 7";
    };
    script = ''
      set -uo pipefail
      if [ ! -f /var/lib/aide/aide.db ]; then
        echo "aide-check: no baseline at /var/lib/aide/aide.db — run aide-init first" >&2
        exit 0
      fi
      ${pkgs.aide}/bin/aide --check --config=/etc/aide.conf
    '';
  };

  systemd.timers.aide-check = {
    description = "AIDE daily integrity check timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar         = "04:00";
      Persistent         = true;
      RandomizedDelaySec = "30m";
    };
  };
}
