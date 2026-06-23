{ config, lib, pkgs, ... }:

let
  ipsecConfPath      = config.sops.templates."ipsec.conf".path;
  strongswanConfPath = config.sops.templates."strongswan.conf".path;
  sshHostSecret      = config.sops.secrets."vpn/ssh_host".path;
  sshUserSecret      = config.sops.secrets."vpn/ssh_user".path;
  vpnWaitSecs        = 60;
  shipToVmScript     = "/home/pixel-peeper/Projects/ACS-INTERNSHIP/work/scripts/ship-to-vm.sh";

  # Shared helpers sourced by acs-work and acs-rofi.
  acsCommon = pkgs.writeShellScript "acs-common" ''
    set -euo pipefail

    ACS_SSH_HOST_FILE="${sshHostSecret}"
    ACS_SSH_USER_FILE="${sshUserSecret}"
    ACS_VPN_WAIT_SECS="''${ACS_VPN_WAIT_SECS:-${toString vpnWaitSecs}}"

    ACS_SSH_OPTS=(
      -o ConnectTimeout=10
      -o StrictHostKeyChecking=accept-new
      -o ServerAliveInterval=30
      -o ServerAliveCountMax=3
    )

    acs_read_ssh_target() {
      SSH_HOST=$(tr -d '[:space:]' < "$ACS_SSH_HOST_FILE" 2>/dev/null || true)
      SSH_USER=$(tr -d '[:space:]' < "$ACS_SSH_USER_FILE" 2>/dev/null || true)
      if [[ -z "$SSH_HOST" || -z "$SSH_USER" ]]; then
        echo "acs: VPN secrets not available under /run/secrets/vpn/" >&2
        return 1
      fi
    }

    acs_vm_reachable() {
      ${pkgs.iputils}/bin/ping -c 1 -W 1 "$SSH_HOST" &>/dev/null \
        || ${pkgs.openssh}/bin/ssh "''${ACS_SSH_OPTS[@]}" -o BatchMode=yes \
             "$SSH_USER@$SSH_HOST" true &>/dev/null
    }

    acs_ensure_vpn() {
      if ${pkgs.systemd}/bin/systemctl is-active --quiet acs-vpn; then
        echo "=> Tunnel already active."
        if acs_vm_reachable; then
          return 0
        fi
        echo "=> Tunnel up but VM unreachable — waiting..."
      else
        echo "=> Spinning up IPsec tunnel..."
        sudo ${pkgs.systemd}/bin/systemctl start acs-vpn
        echo "=> Waiting for data plane (up to ''${ACS_VPN_WAIT_SECS}s)..."
      fi

      local i
      for ((i = 1; i <= ACS_VPN_WAIT_SECS; i++)); do
        if acs_vm_reachable; then
          echo "=> VM reachable after ''${i}s."
          return 0
        fi
        sleep 1
      done

      echo "acs: VM not reachable — check 'journalctl -fu acs-vpn'" >&2
      return 1
    }

    # with_logs=1 adds a right-hand journalctl pane (debugging); default is SSH only.
    acs_open_session() {
      local with_logs="''${1:-0}"

      if ${pkgs.tmux}/bin/tmux has-session -t acs-main 2>/dev/null; then
        echo "=> Attaching to existing session..."
        ${pkgs.kitty}/bin/kitty --class acs-zen \
          ${pkgs.tmux}/bin/tmux attach -t acs-main &
        disown
        return 0
      fi

      echo "=> Forging new session..."
      if [[ "$with_logs" == "1" ]]; then
        ${pkgs.tmux}/bin/tmux new-session -d -s acs-main
        ${pkgs.tmux}/bin/tmux split-window -h -p 35 -t acs-main
        ${pkgs.tmux}/bin/tmux send-keys -t acs-main.2 \
          "sudo journalctl -fu acs-vpn" Enter
        ${pkgs.tmux}/bin/tmux send-keys -t acs-main.1 \
          "ssh acs" Enter
      else
        ${pkgs.tmux}/bin/tmux new-session -d -s acs-main \
          "${pkgs.openssh}/bin/ssh acs"
      fi

      ${pkgs.kitty}/bin/kitty --class acs-zen \
        ${pkgs.tmux}/bin/tmux attach -t acs-main &
      disown
    }

    acs_connect_and_work() {
      local with_logs="''${1:-0}"
      acs_read_ssh_target
      acs_ensure_vpn
      acs_open_session "$with_logs"
    }
  '';
in
{
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-strongswan
  ];

  # Host alias `ssh acs` — host/user injected from SOPS at activation.
  sops.templates."acs-ssh.conf" = {
    owner = "root";
    group = "root";
    mode  = "0644";
    content = ''
      # ACS VM over IPsec VPN — managed by NixOS (do not edit)
      Host acs
          HostName ${config.sops.placeholder."vpn/ssh_host"}
          User ${config.sops.placeholder."vpn/ssh_user"}
          ConnectTimeout 10
          StrictHostKeyChecking accept-new
          ServerAliveInterval 30
          ServerAliveCountMax 3
    '';
  };

  environment.etc."ssh/ssh_config.d/acs.conf".source =
    config.sops.templates."acs-ssh.conf".path;

  environment.systemPackages = with pkgs; [
    strongswan

    # ─── ACS desktop entry (Rofi drun) ─────────────────────────────────────
    (pkgs.makeDesktopItem {
      name        = "acs-vpn";
      desktopName = "ACS VPN";
      comment     = "ACS IPsec VPN Zen Workspace";
      exec        = "acs-rofi";
      icon        = "network-vpn";
      categories  = [ "Network" "Security" ];
    })

    # ─── acs-work ───────────────────────────────────────────────────────────
    # VPN + readiness wait + Kitty on workspace 5 (SSH-only tmux by default).
    (pkgs.writeShellScriptBin "acs-work" ''
      # shellcheck source=/dev/null
      source ${acsCommon}
      acs_connect_and_work "''${ACS_VPN_LOGS:-0}"
    '')

    # ─── acs-kill ───────────────────────────────────────────────────────────
    (pkgs.writeShellScriptBin "acs-kill" ''
      sudo ${pkgs.systemd}/bin/systemctl stop acs-vpn && echo "=> Tunnel severed."
      ${pkgs.tmux}/bin/tmux kill-session -t acs-main 2>/dev/null \
        && echo "=> Session destroyed."
    '')

    # ─── ACS Rofi applet ───────────────────────────────────────────────────
    (pkgs.writeShellScriptBin "acs-rofi" ''
      # shellcheck source=/dev/null
      source ${acsCommon}

      CHOICE=$(printf \
        "󰖂  Connect & Work\n󰖂  Connect with VPN logs\n󰖂  Disconnect\n󰋯  Status\n  Open Terminal\n  Sync work/ to VM" \
        | ${pkgs.rofi}/bin/rofi -dmenu -p "ACS" -i \
            -theme-str 'window {width: 440px;} listview {lines: 6;}')

      case "$CHOICE" in
        "󰖂  Connect & Work")
          acs_connect_and_work 0 \
            || ${pkgs.libnotify}/bin/notify-send -u critical "ACS VPN" "Connect failed — see terminal"
          ;;
        "󰖂  Connect with VPN logs")
          acs_connect_and_work 1 \
            || ${pkgs.libnotify}/bin/notify-send -u critical "ACS VPN" "Connect failed — see terminal"
          ;;
        "󰖂  Disconnect")
          sudo ${pkgs.systemd}/bin/systemctl stop acs-vpn
          ${pkgs.tmux}/bin/tmux kill-session -t acs-main 2>/dev/null || true
          ${pkgs.libnotify}/bin/notify-send "ACS VPN" "Tunnel disconnected."
          ;;
        "󰋯  Status")
          acs_read_ssh_target 2>/dev/null || true
          if ${pkgs.systemd}/bin/systemctl is-active --quiet acs-vpn; then
            ${pkgs.libnotify}/bin/notify-send "ACS VPN" \
              "Tunnel: ACTIVE\nRemote: ''${SSH_USER:-?}@''${SSH_HOST:-?}"
          else
            ${pkgs.libnotify}/bin/notify-send "ACS VPN" "Tunnel: INACTIVE"
          fi
          ;;
        "  Open Terminal")
          acs_open_session "''${ACS_VPN_LOGS:-0}"
          ;;
        "  Sync work/ to VM")
          if [[ ! -x "${shipToVmScript}" ]]; then
            ${pkgs.libnotify}/bin/notify-send -u critical "ACS VPN" \
              "ship-to-vm.sh not found at ${shipToVmScript}"
            exit 1
          fi
          acs_read_ssh_target || exit 1
          acs_ensure_vpn || exit 1
          ${pkgs.libnotify}/bin/notify-send "ACS VPN" "Syncing work/ to VM…"
          "${shipToVmScript}" --sync-only
          ;;
      esac
    '')
  ];

  # ─── SOPS template chain ────────────────────────────────────────────────
  sops.templates."ipsec.conf" = {
    owner   = "root";
    group   = "root";
    mode    = "0600";
    content = ''
      config setup
          charondebug="ike 2, knl 1, cfg 1"
          uniqueids=no

      conn ACS-POC
          keyexchange=ikev1
          authby=xauthpsk
          aggressive=yes

          ike=aes256-sha256-modp2048!
          ikelifetime=86400s

          esp=aes256-sha256-modp2048!
          lifetime=43200s
          rekey=yes

          right=${config.sops.placeholder."vpn/gateway_ip"}
          rightid=%any
          rightsubnet=0.0.0.0/0

          left=%defaultroute
          leftid=%myid
          leftsourceip=%config

          dpdaction=restart
          dpddelay=30s
          dpdtimeout=120s

          type=tunnel
          auto=add

          xauth=client
          xauth_identity=${config.sops.placeholder."vpn/xauth_identity"}
    '';
  };

  sops.templates."strongswan.conf" = {
    owner   = "root";
    group   = "root";
    mode    = "0600";
    content = ''
      charon {
        plugins {
          stroke {
            secrets_file = /etc/ipsec.secrets
          }
        }
      }
      starter {
        config_file = ${ipsecConfPath}
      }
    '';
  };

  services.strongswan = {
    enable  = true;
    secrets = [ config.sops.secrets."ipsec_secrets".path ];
  };

  systemd.services.strongswan.environment.STRONGSWAN_CONF =
    lib.mkForce strongswanConfPath;

  systemd.services."acs-vpn" = {
    description = "ACS IPsec VPN tunnel (ACS-POC connection)";
    requires    = [ "strongswan.service" "network-online.target" ];
    after       = [ "strongswan.service" "network-online.target" ];
    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "acs-vpn-start" ''
        export STRONGSWAN_CONF=${strongswanConfPath}
        exec ${pkgs.strongswan}/sbin/ipsec up ACS-POC
      '';
      ExecStop = pkgs.writeShellScript "acs-vpn-stop" ''
        export STRONGSWAN_CONF=${strongswanConfPath}
        exec ${pkgs.strongswan}/sbin/ipsec down ACS-POC
      '';
    };
  };

  security.sudo.extraRules = [{
    users    = [ "pixel-peeper" ];
    commands = [
      { command = "${pkgs.systemd}/bin/systemctl start acs-vpn";   options = [ "NOPASSWD" ]; }
      { command = "${pkgs.systemd}/bin/systemctl stop acs-vpn";    options = [ "NOPASSWD" ]; }
      { command = "${pkgs.systemd}/bin/systemctl restart acs-vpn"; options = [ "NOPASSWD" ]; }
      {
        command = "${pkgs.systemd}/bin/journalctl -fu acs-vpn";
        options = [ "NOPASSWD" ];
      }
    ];
  }];

  networking.firewall = lib.mkMerge [
    {
      allowedUDPPorts = [ 500 4500 ];
    }
    (lib.mkIf (config.networking.firewall.backend == "nftables") {
      extraInputRules = ''
        meta nfproto ipv4 ip protocol esp accept comment "IPsec ESP"
        meta nfproto ipv6 ip6 nexthdr esp accept comment "IPsec ESP IPv6"
      '';
    })
    (lib.mkIf (config.networking.firewall.backend == "iptables") {
      extraCommands = ''
        ip46tables -A nixos-fw -p esp -j nixos-fw-accept
      '';
    })
  ];
}
