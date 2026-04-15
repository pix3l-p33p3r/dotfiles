#!/usr/bin/env bash
# Polled by hyprpanel custom bar module.
if systemctl is-active --quiet nftables; then
  echo '{"alt":"on","status":""}'
else
  echo '{"alt":"off","status":"!"}'
fi
