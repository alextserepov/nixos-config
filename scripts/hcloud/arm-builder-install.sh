#!/usr/bin/env bash
set -euo pipefail

: "${HCLOUD_TOKEN:?Need HCLOUD_TOKEN set}"

NAME="${HCLOUD_SERVER_NAME:-arm-builder}"
RESCUE_WAIT_SECONDS="${RESCUE_WAIT_SECONDS:-120}"

get_rescue_status() {
  hcloud server describe "$NAME" -o format='{{.RescueEnabled}}'
}

wait_for_rescue_status() {
  local expected="$1"
  local deadline=$((SECONDS + RESCUE_WAIT_SECONDS))
  while true; do
    if [[ "$(get_rescue_status)" == "$expected" ]]; then
      return 0
    fi
    if (( SECONDS >= deadline )); then
      return 1
    fi
    sleep 2
  done
}

if [[ "$(get_rescue_status)" != "true" ]]; then
  echo "Rescue is not enabled for $NAME. Enable rescue before installing."
  exit 1
fi

IP="$(hcloud server describe "$NAME" -o format='{{.PublicNet.IPv4.IP}}')"
if [[ -z "$IP" ]]; then
  echo "No public IPv4 found for $NAME."
  exit 1
fi

echo "Installing to $NAME at $IP (rescue root login)..."

# Run from repo root:
nix run github:nix-community/nixos-anywhere -- \
  --flake ".#arm-builder" \
  --build-on-remote \
  "root@${IP}"

hcloud server disable-rescue "$NAME" || true
hcloud server reboot "$NAME"

if ! wait_for_rescue_status "false"; then
  echo "Rescue did not disable within ${RESCUE_WAIT_SECONDS}s for $NAME."
  exit 1
fi
