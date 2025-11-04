## Shortcuts, Keybinds, and Aliases

This document centralizes the main keyboard shortcuts and CLI aliases across the setup.

### Hyprland Keybinds
- Super refers to the `SUPER` key (Windows key).

- Launchers
  - Super + Return: open terminal
  - Super + Shift + Return: open floating terminal
  - Super + Space: application menu (rofi)
  - Super + Shift + D: run dialog (rofi)
  - Super + F: file manager
  - Super + B: browser
  - Super + X: browser new tab (x.com)
  - Super + G: browser new tab (Gmail)
  - Super + C: Cursor editor
  - Super + V: Vesktop
  - Super + P: toggle Hyprpanel window (dashboard)

- Window management
  - Super + Q: close focused window
  - Super + M: exit Hyprland
  - Super + Shift + Space: toggle floating
  - Super + Shift + F: fullscreen
  - Super + Escape: lock (hyprlock)

- Focus movement
  - Super + H/J/K/L: focus left/down/up/right

- Move window
  - Super + Shift + H/J/K/L: move window left/down/up/right

- Resize window (added)
  - Super + Ctrl + H/L: resize width −/+
  - Super + Ctrl + K/J: resize height −/+

- Workspaces
  - Super + 1..0: switch workspace 1..10
  - Super + Shift + 1..0: move window to workspace 1..10
  - Super + S: toggle special workspace "magic"
  - Super + Shift + S: move window to special workspace "magic"

- Mouse
  - Alt + Left-drag: move window
  - Alt + Shift + Left-drag: resize window

- Clipboard & utilities
  - Super + Shift + V: clipboard history (cliphist + rofi)
  - Super + Shift + C: color picker (hyprpicker)

- Media & brightness
  - XF86AudioRaiseVolume / Lower / Mute / Play / Next / Prev
  - XF86MonBrightnessUp / Down

### Zsh Aliases
- Listings and navigation
  - l, ls: eza (icons) | lsa: eza -lah | ll: eza -lh
  - d: show directory stack | 1..9: cd to Nth stack entry
  - cd: zoxide | vi: nvim | e: $EDITOR
  - path: print PATH lines | o: xdg-open

- Sanity helpers
  - cp: cp -ri | rm: rm -i | df: df -h | makej: make -j $(nproc)
  - grep: grep --color=auto | mkdir: mkdir -p | cat: bat --plain
  - pg: ping 1.0.0.1 -c 5 | myip: curl icanhazip.com

- Nix helpers
  - clean: scripts/nix-cleaner.sh
  - nrs: NixOS rebuild (system)
  - hms: Home Manager switch (user)
  - update: flake update + fastfetch
  - upgrade: nrs + hms + clean + fastfetch
  - check: nix flake check | nsize | nsearch | nwhy | nfdiff | nbuild
  - mcp: run MCP for NixOS | timezsh: zsh startup timing

- Taskwarrior / Timewarrior
  - t: task | ta: task add | tt: task +PENDING limit:20
  - td: task done | tdel: task delete | tmod: task modify
  - tstart: timew start | tstop: timew stop | tw: timew
  - twday: timew summary :day | tww: timew summary :week | twg: timew gaps :week
  - twsync: start Timewarrior sync server

### Tips
- Start a task and auto-track time (hook): `task start <ID>`
- Stop/complete a task (auto-stop time): `task done <ID>` or `task stop <ID>`
- Resize windows quickly when floating or in tiling mode with Super+Ctrl H/J/K/L.


