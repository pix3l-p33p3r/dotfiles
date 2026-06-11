#!/usr/bin/env bash
# Waydroid control menu for Rofi (start, stop, status, apps, etc.)
set -euo pipefail

notify() {
  notify-send -a waydroid -i phone "Waydroid" "$1"
}

stop_container() {
  if command -v run0 >/dev/null 2>&1; then
    run0 -- waydroid container stop
  else
    sudo waydroid container stop
  fi
}

launch_app_menu() {
  mapfile -t lines < <(
    waydroid app list 2>/dev/null | awk '
      /^Name:/ {
        sub(/^Name: /, "")
        name = $0
      }
      /^packageName:/ {
        sub(/^packageName: /, "")
        pkg = $0
      }
      /android.intent.category.LAUNCHER/ {
        if (name != "" && pkg != "") {
          printf "%s\t%s\n", name, pkg
          name = ""
          pkg = ""
        }
      }
    '
  )

  if [ "${#lines[@]}" -eq 0 ]; then
    notify "No launcher apps found. Start the session first."
    return
  fi

  choice=$(
    printf '%s\n' "${lines[@]}" \
      | rofi -dmenu -i -p " Android apps" -format i
  )

  [ -z "$choice" ] && return

  pkg=$(printf '%s\n' "${lines[@]}" | sed -n "${choice}p" | cut -f2)
  [ -n "$pkg" ] && waydroid app launch "$pkg"
}

main_menu() {
  local options=(
    "Open Android UI"
    "Google Play Store"
    "Start session"
    "Stop session"
    "Stop container (full)"
    "Status"
    "Launch app…"
    "Android shell"
  )

  choice=$(
    printf '%s\n' "${options[@]}" | rofi -dmenu -i -p " Android"
  )

  case "$choice" in
    "Open Android UI")
      waydroid session start 2>/dev/null || true
      waydroid show-full-ui
      ;;
    "Google Play Store")
      waydroid session start 2>/dev/null || true
      waydroid app launch com.android.vending
      ;;
    "Start session")
      waydroid session start
      notify "Session started"
      ;;
    "Stop session")
      waydroid session stop
      notify "Session stopped"
      ;;
    "Stop container (full)")
      waydroid session stop 2>/dev/null || true
      stop_container
      notify "Container stopped"
      ;;
    "Status")
      status=$(waydroid status 2>&1 | tr '\n' ' · ' | sed 's/ · $//')
      notify "${status:-unknown}"
      ;;
    "Launch app…")
      waydroid session start 2>/dev/null || true
      launch_app_menu
      ;;
    "Android shell")
      waydroid session start 2>/dev/null || true
      exec waydroid shell
      ;;
    "" | *)
      exit 0
      ;;
  esac
}

main_menu
