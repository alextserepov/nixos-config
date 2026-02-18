#!/usr/bin/env bash
set -euo pipefail

NAME="arm-builder"

IP="$(hcloud server describe "$NAME" -o format='{{.PublicNet.IPv4.IP}}')"
echo "Installing to $NAME at $IP (rescue root login)..."

# Run from repo root:
nix run github:nix-community/nixos-anywhere -- \
  --flake ".#arm-builder" \
  --build-on-remote \
  "root@${IP}"

hcloud server disable-rescue "$NAME" || true
hcloud server reboot "$NAME"
