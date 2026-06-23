#!/usr/bin/env bash
# Convert a Microsoft Windows ESD (from winiso/MCT catalog) to a bootable ISO.
# Based on https://github.com/mattieb/windows-esd-to-iso (MIT) — Linux ISO step.
set -euo pipefail

log() { printf '[winapps-esd] %s\n' "$*"; }
die() { printf '[winapps-esd] ERROR: %s\n' "$*" >&2; exit 1; }

usage() {
  echo "Usage: $0 SOURCE.esd [OUTPUT.iso]"
  exit 1
}

[[ $# -ge 1 ]] || usage
esd="$(readlink -f "$1")"
[[ -f "$esd" ]] || die "ESD not found: $esd"

out="${2:-}"
if [[ -z "$out" ]]; then
  out="$(dirname "$esd")/win11x64.iso"
else
  out="$(readlink -f "$out")"
fi

if ! command -v wiminfo >/dev/null 2>&1 || ! command -v xorriso >/dev/null 2>&1; then
  if command -v nix >/dev/null 2>&1; then
    exec nix shell nixpkgs#wimlib nixpkgs#xorriso -c "$0" "$@"
  fi
  die "missing wimlib/xorriso — run: nix shell nixpkgs#wimlib nixpkgs#xorriso -c $0 …"
fi

if [[ -s "$out" ]]; then
  log "ISO already exists: $out"
  exit 0
fi

tmpdir="$(mktemp -d)"
cleanup() {
  if [[ -z "${NO_CLEANUP:-}" ]]; then
    rm -rf "$tmpdir"
  else
    log "NO_CLEANUP set — kept $tmpdir"
  fi
}
trap cleanup EXIT

log "Exporting images from $(basename "$esd")…"
image_count="$(wiminfo "$esd" --header | awk -F= '/^Image Count/ {gsub(/ /,"",$2); print $2}')"
[[ "${image_count:-0}" -gt 0 ]] || die "could not read ESD image count"

log "Found $image_count images"
wimapply "$esd" 1 "$tmpdir"

wimexport "$esd" 2 "${tmpdir}/sources/boot.wim" --compress=LZX --chunk-size=32K
wimexport "$esd" 3 "${tmpdir}/sources/boot.wim" --compress=LZX --chunk-size=32K --boot

# Export one edition only (default: 9 = Windows 11 Pro). Merging all consumer
# editions into install.esd can OOM on machines with <32 GiB RAM.
edition_index="${WINAPPS_EDITION_INDEX:-9}"
edition_name="$(wiminfo "$esd" "$edition_index" | awk -F': ' '/^Name:/ {print $2; exit}')"
log "Exporting edition $edition_index ($edition_name)…"
wimexport "$esd" "$edition_index" "${tmpdir}/sources/install.esd" \
  --compress=LZX --chunk-size=32K --threads=4

efisys="${tmpdir}/efi/microsoft/boot/efisys.bin"
efisys_np="${tmpdir}/efi/microsoft/boot/efisys_noprompt.bin"
[[ -f "$efisys" ]] || die "missing UEFI boot image in ESD export"

log "Creating ISO → $out"
rm -f "$out"
(
  cd "$tmpdir"
  xorriso -as mkisofs \
    -iso-level 3 \
    -udf \
    -eltorito-boot efi/microsoft/boot/efisys.bin \
    -no-emul-boot \
    -eltorito-alt-boot \
    -e efi/microsoft/boot/efisys_noprompt.bin \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -V "CCCOMA_X64FREV_EN-US_DV9" \
    -o "$out" \
    .
)

log "Done: $(du -h "$out" | cut -f1) → $out"
