#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  exec sudo -E -H "$0" "$@"
fi

: "${HCLOUD_TOKEN:?Need HCLOUD_TOKEN set}"

NAME="${HCLOUD_SERVER_NAME:-arm-builder}"
SSH_WAIT_SECONDS="${SSH_WAIT_SECONDS:-240}"
SSH_USER="${SSH_USER:-alextserepov}"
if [[ -n "${HCLOUD_SSH_IDENTITY:-}" ]]; then
  SSH_IDENTITY="$HCLOUD_SSH_IDENTITY"
elif [[ "${EUID:-$(id -u)}" -eq 0 && -n "${SUDO_USER:-}" ]]; then
  SSH_IDENTITY="/home/${SUDO_USER}/.ssh/id_ed25519"
else
  SSH_IDENTITY="$HOME/.ssh/id_ed25519"
fi

wait_for_ssh() {
  local ip="$1"
  local deadline=$((SECONDS + SSH_WAIT_SECONDS))
  while true; do
    if ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
      -o ConnectTimeout=5 -o BatchMode=yes -o IdentitiesOnly=yes -i "$SSH_IDENTITY" \
      "${SSH_USER}@${ip}" true; then
      return 0
    fi
    if (( SECONDS >= deadline )); then
      return 1
    fi
    sleep 5
  done
}

arm-builder-up
arm-builder-rescue
arm-builder-install

IP="$(hcloud server describe "$NAME" -o format='{{.PublicNet.IPv4.IP}}')"
if [[ -z "$IP" ]]; then
  echo "No public IPv4 found for $NAME."
  exit 1
fi

echo "Waiting for SSH on $NAME ($IP) as ${SSH_USER}..."
if ! wait_for_ssh "$IP"; then
  echo "SSH not up after install; issuing one extra reboot for $NAME..."
  hcloud server reboot "$NAME"
  if ! wait_for_ssh "$IP"; then
    echo "SSH still not reachable after extra reboot."
    exit 1
  fi
fi

echo "SSH is up on $NAME."

arm-builder-trust
