#!/usr/bin/env bash
# Install winiso (Microsoft catalog downloader) into a local venv.
set -euo pipefail

VENV="${WINISO_VENV:-$HOME/.local/share/winiso-venv}"
REPO="${WINISO_REPO:-/tmp/winiso}"

if [[ -x "$VENV/bin/winiso" ]]; then
  exit 0
fi

mkdir -p "$(dirname "$VENV")"
if [[ ! -d "$REPO/.git" ]]; then
  git clone --depth 1 https://github.com/Xatter/winiso.git "$REPO"
fi

python3 -m venv "$VENV"
# shellcheck disable=SC1091
source "$VENV/bin/activate"
pip install -q -U pip
pip install -q -e "$REPO"

command -v "$VENV/bin/winiso" >/dev/null
