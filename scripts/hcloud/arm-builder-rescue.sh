#!/usr/bin/env bash
set -euo pipefail
: "${HCLOUD_TOKEN:?Need HCLOUD_TOKEN set}"

NAME="${HCLOUD_SERVER_NAME:-arm-builder}"
SSH_KEY="${HCLOUD_SSH_KEY_NAME:-id_ed25519.pub}"

echo "Enabling rescue mode on $NAME ..."
hcloud server enable-rescue "$NAME" --type linux64 --ssh-key "$SSH_KEY"

echo "Rebooting into rescue..."
hcloud server reboot "$NAME"

IP="$(hcloud server ip "$NAME")"

echo
echo "Waiting for rescue SSH (root@$IP)..."

for i in {1..60}; do
 if ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@"$IP" true; then
    echo "Rescue SSH is up."
    exit 0
  fi
  sleep 2
done

echo "Rescue SSH did not come up in time."
exit 1
