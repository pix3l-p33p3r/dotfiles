#!/usr/bin/env bash
# WinApps / Windows VM control menu for Rofi.
set -euo pipefail

vm="${WINAPPS_VM_NAME:-RDPWindows}"

notify() {
  notify-send -a winapps -i computer "WinApps" "$1"
}

vm_state() {
  virsh domstate "$vm" 2>/dev/null || echo "missing"
}

start_vm() {
  if [[ "$(vm_state)" == "running" ]]; then
    notify "VM already running"
    return
  fi
  virsh start "$vm"
  notify "Starting $vm…"
}

stop_vm() {
  local state
  state="$(vm_state)"
  if [[ "$state" == "missing" ]]; then
    notify "VM '$vm' not found — create it in virt-manager first"
    return
  fi
  if [[ "$state" != "running" ]]; then
    notify "VM is not running ($state)"
    return
  fi
  virsh shutdown "$vm"
  notify "Shutting down $vm…"
}

main_menu() {
  local state
  state="$(vm_state)"

  local options=(
    "Comet browser"
    "WinApps launcher"
    "Windows desktop (full RDP)"
    "Add / refresh apps (winapps-setup)"
    "Start VM ($state)"
    "Stop VM"
    "VM status: $state"
  )

  choice=$(
    printf '%s\n' "${options[@]}" | rofi -dmenu -i -p " Windows"
  )

  case "$choice" in
    "Comet browser")
      app=$(
        find "$HOME/.local/share/applications" -maxdepth 1 -iname '*comet*.desktop' -print -quit
      )
      if [[ -n "$app" ]]; then
        gtk-launch "$(basename "$app" .desktop)"
      else
        notify "Register Comet first: winapps-setup --user --add-apps"
        winapps-setup --user --add-apps
      fi
      ;;
    "WinApps launcher")
      exec winapps-launcher
      ;;
    "Windows desktop (full RDP)")
      winapps windows
      ;;
    "Add / refresh apps (winapps-setup)")
      winapps-setup --user --add-apps
      ;;
    "Start VM ($state)")
      start_vm
      ;;
    "Stop VM")
      stop_vm
      ;;
    "" | "VM status: $state")
      exit 0
      ;;
    *)
      exit 0
      ;;
  esac
}

main_menu
