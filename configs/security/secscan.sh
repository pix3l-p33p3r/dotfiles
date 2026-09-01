#!/usr/bin/env bash
# security-scan — trigger AIDE + Lynis on demand, wait, summarize results.
#
# Usage:
#   security-scan            # all three: AIDE + Lynis + Vulnix
#   security-scan aide       # just the AIDE integrity check
#   security-scan lynis      # just the Lynis audit
#   security-scan vulnix     # just the Vulnix CVE scan
#   security-scan baseline   # rebuild AIDE baseline (use after legit system changes)
#
# Reads systemd unit state and journal output — needs sudo for `systemctl
# start` and for reading /var/log/lynis + /var/log/vulnix.

set -euo pipefail

# ── colors ─────────────────────────────────────────────────────────────────
if [ -t 1 ] && [ "${NO_COLOR:-}" = "" ]; then
  bold=$'\e[1m';   dim=$'\e[2m';     reset=$'\e[0m'
  red=$'\e[31m';   green=$'\e[32m';  yellow=$'\e[33m';  blue=$'\e[34m'
else
  bold=''; dim=''; reset=''; red=''; green=''; yellow=''; blue=''
fi

say()  { printf '%s==>%s %s\n'   "$blue"   "$reset" "$*"; }
ok()   { printf '%s ✓%s %s\n'    "$green"  "$reset" "$*"; }
warn() { printf '%s ‼%s %s\n'    "$yellow" "$reset" "$*"; }
err()  { printf '%s ✗%s %s\n'    "$red"    "$reset" "$*" >&2; }

# ── helpers ────────────────────────────────────────────────────────────────

# Wait until `systemctl is-active <unit>` returns inactive/failed, with a
# spinner and elapsed time.  Caps at $2 seconds (default 1800 = 30 min).
wait_for_unit() {
  local unit="$1"
  local timeout="${2:-1800}"
  local frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local start
  start="$(date +%s)"
  local i=0

  while :; do
    local state
    state="$(systemctl is-active "$unit" 2>/dev/null || true)"
    if [ "$state" != "active" ] && [ "$state" != "activating" ]; then
      printf '\r\033[K'      # clear the spinner line
      return 0
    fi

    local now elapsed
    now="$(date +%s)"
    elapsed=$(( now - start ))
    if [ "$elapsed" -ge "$timeout" ]; then
      printf '\r\033[K'
      err "$unit timed out after ${timeout}s"
      return 1
    fi

    local frame="${frames:$((i % ${#frames})):1}"
    printf '\r%s%s%s %s   running for %dm%02ds   ' \
      "$dim" "$frame" "$reset" "$unit" $((elapsed / 60)) $((elapsed % 60))
    i=$((i + 1))
    sleep 0.5
  done
}

# Trigger a oneshot service and block until it finishes.  $1 = unit name,
# $2 = optional timeout in seconds.
run_unit() {
  local unit="$1"
  local timeout="${2:-1800}"

  say "$unit ${dim}(starting)${reset}"
  if ! sudo systemctl start "$unit"; then
    err "failed to start $unit"
    return 1
  fi

  wait_for_unit "$unit" "$timeout"

  local result
  result="$(systemctl show -p Result --value "$unit" 2>/dev/null || echo unknown)"
  local code
  code="$(systemctl show -p ExecMainStatus --value "$unit" 2>/dev/null || echo unknown)"

  case "$result" in
    success)         ok "$unit completed (exit=$code)" ;;
    exit-code)       warn "$unit exited non-zero (exit=$code) — see journal" ;;
    *)               warn "$unit result=$result (exit=$code)" ;;
  esac
}

# ── individual scans ───────────────────────────────────────────────────────

run_aide_check() {
  printf '\n%s── AIDE integrity check ──%s\n' "$bold" "$reset"
  if ! sudo test -f /var/lib/aide/aide.db; then
    warn "no AIDE baseline yet — run \`security-scan baseline\` first"
    return 1
  fi
  run_unit aide-check.service 1800

  # Pull the verdict from journal
  local verdict
  verdict="$(sudo journalctl -u aide-check.service -n 200 --no-pager --since '5 min ago' \
              | grep -E 'AIDE found|differences' | tail -1 || true)"
  if [ -n "$verdict" ]; then
    echo "$verdict" \
      | sed -E "s/.*found NO differences.*/$green&$reset/; s/.*found.*differences.*/$red&$reset/"
  fi
}

run_aide_init() {
  printf '\n%s── AIDE baseline rebuild ──%s\n' "$bold" "$reset"
  warn "this rebuilds /var/lib/aide/aide.db — only do this AFTER intentional system changes (nrs)"
  read -r -p "Continue? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { say "aborted"; return 0; }
  run_unit aide-init.service 1800
}

run_lynis() {
  printf '\n%s── Lynis security audit ──%s\n' "$bold" "$reset"
  run_unit lynis-audit.service 600

  # Lynis writes /var/log/lynis/report.dat — extract the headline numbers
  if sudo test -r /var/log/lynis/report.dat; then
    printf '\n%sSummary:%s\n' "$bold" "$reset"

    local idx
    idx="$(sudo grep -E '^hardening_index=' /var/log/lynis/report.dat | tail -1 | cut -d= -f2 || true)"
    if [ -n "$idx" ]; then
      local color="$green"
      [ "$idx" -lt 80 ] && color="$yellow"
      [ "$idx" -lt 60 ] && color="$red"
      printf '  Hardening index : %s%s/100%s\n' "$color" "$idx" "$reset"
    fi

    # grep returns exit 1 on no-match; combined with `set -o pipefail` this
    # kills the script.  Wrap each pipeline so it can fail safely.
    local warns suggs
    warns="$( { sudo grep '^warning\['   /var/log/lynis/report.dat || true; } 2>/dev/null | wc -l)"
    suggs="$( { sudo grep '^suggestion\[' /var/log/lynis/report.dat || true; } 2>/dev/null | wc -l)"
    # Strip whitespace from wc -l (it pads on some systems)
    warns="${warns//[[:space:]]/}"
    suggs="${suggs//[[:space:]]/}"
    printf '  Warnings        : %s%d%s\n' "$([ "${warns:-0}" -gt 0 ] && echo "$yellow" || echo "$green")" "${warns:-0}" "$reset"
    printf '  Suggestions     : %d\n' "${suggs:-0}"

    if [ "$warns" -gt 0 ]; then
      printf '\n%sTop warnings:%s\n' "$bold" "$reset"
      sudo grep '^warning\[' /var/log/lynis/report.dat \
        | head -5 \
        | sed -E 's/^warning\[[^]]+\]=/  • /'
    fi

    printf '\n%sFull report :%s sudo less /var/log/lynis/lynis.log\n' "$dim" "$reset"
    printf '%sRaw data    :%s sudo less /var/log/lynis/report.dat\n'   "$dim" "$reset"
  fi
}

run_vulnix() {
  printf '\n%s── Vulnix CVE scan ──%s\n' "$bold" "$reset"
  run_unit vulnix-scan.service 1800

  # Pull the verdict from journal (the systemd unit prints a "vulnix: N
  # affected derivations" summary as part of its script).
  local last
  last="$(sudo journalctl -u vulnix-scan.service -n 200 --no-pager --since '10 min ago' \
            | grep -E 'vulnix: [0-9]+ affected' | tail -1 || true)"
  if [ -n "$last" ]; then
    local n
    n="$(echo "$last" | grep -oE '[0-9]+' | head -1)"
    local color="$green"
    [ "$n" -gt 0 ]  && color="$yellow"
    [ "$n" -gt 10 ] && color="$red"
    printf '\n%sSummary:%s\n' "$bold" "$reset"
    printf '  Affected derivations : %s%d%s\n' "$color" "$n" "$reset"
    if [ "$n" -gt 0 ]; then
      printf '\n%sTop offenders:%s\n' "$bold" "$reset"
      sudo journalctl -u vulnix-scan.service -n 200 --no-pager --since '10 min ago' \
        | grep -E '^\s+• ' | head -10
    fi
    printf '\n%sJSON report :%s sudo less /var/log/vulnix/vulnix.json\n' "$dim" "$reset"
    printf '%sFull log    :%s sudo less /var/log/vulnix/vulnix.log\n'   "$dim" "$reset"
  else
    warn "couldn't parse vulnix output — see: sudo journalctl -u vulnix-scan -n 50"
  fi
}

# ── dispatch ───────────────────────────────────────────────────────────────

case "${1:-all}" in
  aide)     run_aide_check ;;
  baseline) run_aide_init ;;
  lynis)    run_lynis ;;
  vulnix)   run_vulnix ;;
  all|"")   run_aide_check; run_lynis; run_vulnix ;;
  -h|--help)
    sed -n '/^# Usage:/,/^$/p' "$0" | sed 's/^# \?//'
    ;;
  *)
    err "unknown argument: $1"
    err "valid: aide | baseline | lynis | vulnix | all"
    exit 1
    ;;
esac
