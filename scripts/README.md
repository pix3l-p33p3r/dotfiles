# Scripts

Operational helpers live in the Nix closure (`writeShellApplication` / `nh`). Three tiny shims remain so **already-open** shells with old aliases (`clean`, `secscan`, `upgrade`) do not 127; they only `exec` the store/`nh` commands.

| Command | From |
|---------|------|
| `nh os switch` / `nrs` | `programs.nh` |
| `nh home switch -c 'pixel-peeper@alucard'` / `hms` | `programs.nh` |
| `nix-clean` / `clean` | `homes/pixel-peeper/cli.nix` |
| `secscan` | `configs/security/secscan.sh` packaged in cli.nix |
| `hw-accel` | `configs/desktop/hw-accel.sh` packaged in cli.nix |
| `nix-dns-recover` | cli.nix |
| `winapps-create-vm` / `winapps-status` | `configs/desktop/winapps` |
| `sudo nix run .#facter -- -o /tmp/facter.json` | flake app |

Windows-only leftover (run inside the VM):

| File | Purpose |
|------|---------|
| `winapps-windows-oem.bat` | WinApps OEM setup on Windows |
