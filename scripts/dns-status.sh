#!/usr/bin/env bash
# Polled by hyprpanel custom bar module.
CURRENT=$(resolvectl dns 2>/dev/null | head -1)
if echo "$CURRENT" | grep -qE "(extended|base|adblock|all)\.dns\.mullvad"; then
  echo '{"alt":"filter","status":""}'
else
  echo '{"alt":"plain","status":"!"}'
fi
