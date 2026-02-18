#!/usr/bin/env bash
set -euo pipefail

: "${HCLOUD_TOKEN:?Need HCLOUD_TOKEN set}"

NAME="${HCLOUD_SERVER_NAME:-arm-builder}"
RESCUE_WAIT_SECONDS="${RESCUE_WAIT_SECONDS:-120}"
if [[ -n "${HCLOUD_SSH_IDENTITY:-}" ]]; then
  SSH_IDENTITY="$HCLOUD_SSH_IDENTITY"
elif [[ "${EUID:-$(id -u)}" -eq 0 && -n "${SUDO_USER:-}" ]]; then
  SSH_IDENTITY="/home/${SUDO_USER}/.ssh/id_ed25519"
else
  SSH_IDENTITY="$HOME/.ssh/id_ed25519"
fi

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

IP="$(hcloud server describe "$NAME" -o format='{{.PublicNet.IPv4.IP}}')"
if [[ -z "$IP" ]]; then
  echo "No public IPv4 found for $NAME."
  exit 1
fi

if [[ "$(get_rescue_status)" != "true" ]]; then
  echo "Rescue not yet reported by API; probing via SSH..."
  if ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -o ConnectTimeout=5 -o BatchMode=yes -o IdentitiesOnly=yes -i "$SSH_IDENTITY" \
    "root@${IP}" \
    "grep -qi rescue /etc/issue 2>/dev/null || grep -qi rescue /etc/os-release 2>/dev/null"; then
    echo "Rescue detected via SSH, proceeding despite API reporting disabled."
  else
    echo "Rescue is not enabled for $NAME. Enable rescue before installing."
    exit 1
  fi
fi

echo "Installing to $NAME at $IP (rescue root login)..."

# Run from repo root:
nix run github:nix-community/nixos-anywhere -- \
  --flake ".#arm-builder" \
  --build-on remote \
  -i "$SSH_IDENTITY" \
  --ssh-option "IdentitiesOnly=yes" \
  --ssh-option "UserKnownHostsFile=/dev/null" \
  --ssh-option "StrictHostKeyChecking=no" \
  --ssh-option "BatchMode=yes" \
  "root@${IP}"

hcloud server disable-rescue "$NAME" || true
hcloud server reboot "$NAME"

if ! wait_for_rescue_status "false"; then
  echo "Rescue did not disable within ${RESCUE_WAIT_SECONDS}s for $NAME."
  exit 1
fi
