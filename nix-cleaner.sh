#!/usr/bin/env bash
# A script to run a full Nix garbage collection and optimization.

# Stop the script if any command fails
set -e

echo "--- [USER] Step 1 of 4: Expiring Home Manager generations (keeping last 2) ---"
# This keeps the current and previous generation, deleting all others.
# We target the home-manager profile directly using nix-env.
# This is the default XDG path for the home-manager profile.
HM_PROFILE="$HOME/.local/state/nix/profiles/home-manager"

if [ -L "$HM_PROFILE" ]; then
    nix-env --profile "$HM_PROFILE" --delete-generations +2
    echo "Home Manager generations cleaned (kept last 2)."
else
    echo "WARNING: Home Manager profile not found at $HM_PROFILE."
    echo "If you use a non-default path, please edit this script."
    echo "Skipping Home Manager generation cleanup."
fi
echo ""

echo "--- [USER] Step 2 of 4: Cleaning other user generations ---"
# This cleans up any other user-level profiles (e.g., from 'nix profile')
nix-collect-garbage -d
echo "Other user generations cleaned."
echo ""

echo "--- [ROOT] Step 3 of 4: Cleaning system generations & collecting garbage ---"
echo "This will ask for your password."
# As root, this cleans up old NixOS system generations AND
# permanently deletes all unreferenced packages from /nix/store.
sudo nix-collect-garbage -d
echo "System garbage collected."
echo ""

echo "--- [ROOT] Step 4 of 4: Optimizing the Nix store ---"
echo "This may also ask for your password."
# As root, this finds identical files in the store and hardlinks them to save space.
sudo nix store optimise
echo "Nix store optimise."
echo ""

echo "--- Nix Cleanup Complete! ---"


