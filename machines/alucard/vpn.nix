{ config, lib, pkgs, ... }:

let
  ipsecConfPath      = config.sops.templates."ipsec.conf".path;
  strongswanConfPath = config.sops.templates."strongswan.conf".path;
in
{
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-strongswan
  ];

  environment.systemPackages = with pkgs; [
    strongswan

    # ─── ACS desktop entry (Rofi drun) ─────────────────────────────────────
    # Shows up as "ACS VPN" in Rofi's drun mode — no dedicated keybinding.
    (pkgs.makeDesktopItem {
      name        = "acs-vpn";
      desktopName = "ACS VPN";
      comment     = "ACS IPsec VPN Zen Workspace";
      exec        = "acs-rofi";
      icon        = "network-vpn";
      categories  = [ "Network" "Security" ];
    })

    # ─── acs-work ───────────────────────────────────────────────────────────
    # Brings up the IPsec tunnel, waits for the data plane, then opens Kitty
    # on workspace 5 with a local tmux split (SSH left | VPN logs right).
    (pkgs.writeShellScriptBin "acs-work" ''
      SSH_HOST=$(cat ${config.sops.secrets."vpn/ssh_host".path} 2>/dev/null)
      SSH_USER=$(cat ${config.sops.secrets."vpn/ssh_user".path} 2>/dev/null)

      if [[ -z "$SSH_HOST" || -z "$SSH_USER" ]]; then
        echo "acs-work: VPN secrets not available at /run/secrets/vpn/" >&2
        exit 1
      fi

      if ! ${pkgs.systemd}/bin/systemctl is-active --quiet acs-vpn; then
        echo "=> Spinning up IPsec tunnel..."
        sudo ${pkgs.systemd}/bin/systemctl start acs-vpn

        echo "=> Waiting for data plane..."
        for i in {1..15}; do
          ${pkgs.iputils}/bin/ping -c 1 -W 1 "$SSH_HOST" &>/dev/null && break
          sleep 1
        done

        if ! ${pkgs.iputils}/bin/ping -c 1 -W 1 "$SSH_HOST" &>/dev/null; then
          echo "acs-work: tunnel timed out — check 'journalctl -fu acs-vpn'" >&2
          exit 1
        fi
      else
        echo "=> Tunnel already active."
      fi

      if ${pkgs.tmux}/bin/tmux has-session -t acs-main 2>/dev/null; then
        echo "=> Attaching to existing session..."
        ${pkgs.kitty}/bin/kitty --class acs-zen \
          ${pkgs.tmux}/bin/tmux attach -t acs-main &
        disown
      else
        echo "=> Forging new session..."
        ${pkgs.kitty}/bin/kitty --class acs-zen \
          ${pkgs.tmux}/bin/tmux new-session -s acs-main \; \
            split-window -h -p 35 \; \
            send-keys "sudo journalctl -fu acs-vpn" Enter \; \
            select-pane -t 0 \; \
            send-keys "ssh -o 'SetEnv TERM=tmux-256color' $SSH_USER@$SSH_HOST" Enter &
        disown
      fi
    '')

    # ─── acs-kill ───────────────────────────────────────────────────────────
    # Tears down the tunnel and destroys the local tmux session.
    (pkgs.writeShellScriptBin "acs-kill" ''
      sudo ${pkgs.systemd}/bin/systemctl stop acs-vpn && echo "=> Tunnel severed."
      ${pkgs.tmux}/bin/tmux kill-session -t acs-main 2>/dev/null && echo "=> Session destroyed."
    '')

    # ─── ACS Rofi applet ───────────────────────────────────────────────────
    # Presents a dmenu of VPN actions; reads runtime values from SOPS secrets
    # so no credentials appear in the Nix store or shell history.
    (pkgs.writeShellScriptBin "acs-rofi" ''
      SSH_HOST=$(cat ${config.sops.secrets."vpn/ssh_host".path} 2>/dev/null)
      SSH_USER=$(cat ${config.sops.secrets."vpn/ssh_user".path} 2>/dev/null)

      CHOICE=$(printf "󰖂  Connect\n󰖂  Disconnect\n󰋯  Status\n  Open Terminal" \
        | ${pkgs.rofi}/bin/rofi -dmenu -p "ACS" -i \
            -theme-str 'window {width: 420px;} listview {lines: 4;}')

      case "$CHOICE" in
        "󰖂  Connect")
          sudo ${pkgs.systemd}/bin/systemctl start acs-vpn
          ${pkgs.libnotify}/bin/notify-send "ACS VPN" "Tunnel connecting…"
          ;;
        "󰖂  Disconnect")
          sudo ${pkgs.systemd}/bin/systemctl stop acs-vpn
          ${pkgs.tmux}/bin/tmux kill-session -t acs-main 2>/dev/null
          ${pkgs.libnotify}/bin/notify-send "ACS VPN" "Tunnel disconnected."
          ;;
        "󰋯  Status")
          if ${pkgs.systemd}/bin/systemctl is-active --quiet acs-vpn; then
            ${pkgs.libnotify}/bin/notify-send "ACS VPN" "Tunnel: ACTIVE\nRemote: $SSH_USER@$SSH_HOST"
          else
            ${pkgs.libnotify}/bin/notify-send "ACS VPN" "Tunnel: INACTIVE"
          fi
          ;;
        "  Open Terminal")
          if ${pkgs.tmux}/bin/tmux has-session -t acs-main 2>/dev/null; then
            ${pkgs.kitty}/bin/kitty --class acs-zen \
              ${pkgs.tmux}/bin/tmux attach -t acs-main &
            disown
          else
            ${pkgs.kitty}/bin/kitty --class acs-zen \
              ${pkgs.tmux}/bin/tmux new-session -s acs-main \; \
                split-window -h -p 35 \; \
                send-keys "sudo journalctl -fu acs-vpn" Enter \; \
                select-pane -t 0 \; \
                send-keys "ssh -o 'SetEnv TERM=tmux-256color' $SSH_USER@$SSH_HOST" Enter &
            disown
          fi
          ;;
      esac
    '')
  ];

  # ─── SOPS template chain ────────────────────────────────────────────────
  # ipsec.conf: rendered at activation with gateway_ip + xauth_identity
  # injected from encrypted SOPS values — never stored in the Nix store.
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

  # strongswan.conf: overrides the Nix store config_file path the module
  # normally generates, pointing starter at our SOPS-rendered ipsec.conf.
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

  # Redirect the strongswan service to use our rendered strongswan.conf
  # instead of the empty Nix store version the module generates.
  systemd.services.strongswan.environment.STRONGSWAN_CONF =
    lib.mkForce strongswanConfPath;

  # ─── acs-vpn oneshot service ────────────────────────────────────────────
  # Controlled via: sudo systemctl start/stop acs-vpn
  # Sudoers rules below grant pixel-peeper passwordless access to these two.
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

  # Passwordless sudo for acs-vpn — required by the Rofi applet and
  # acs-work zsh function which both run in non-interactive contexts.
  security.sudo.extraRules = [{
    users    = [ "pixel-peeper" ];
    commands = [
      { command = "${pkgs.systemd}/bin/systemctl start acs-vpn";   options = [ "NOPASSWD" ]; }
      { command = "${pkgs.systemd}/bin/systemctl stop acs-vpn";    options = [ "NOPASSWD" ]; }
      { command = "${pkgs.systemd}/bin/systemctl restart acs-vpn"; options = [ "NOPASSWD" ]; }
    ];
  }];

  # ─── Firewall ───────────────────────────────────────────────────────────
  # IKE (500), NAT-T (4500), and ESP (proto 50) for the IPsec data plane
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
