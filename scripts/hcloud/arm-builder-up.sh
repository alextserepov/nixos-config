#!/usr/bin/env bash
set -euo pipefail
: "${HCLOUD_TOKEN:?Need HCLOUD_TOKEN set}"

NAME="${HCLOUD_SERVER_NAME:-arm-builder}"
TYPE="${HCLOUD_SERVER_TYPE:-cax21}"
IMAGE="${HCLOUD_BOOT_IMAGE:-ubuntu-24.04}"
LOCATION="${HCLOUD_LOCATION:-hel1}"
PRIMARY_IPV4="${HCLOUD_PRIMARY_IPV4_NAME:-arm-builder-ip1}"
SSH_KEY="${HCLOUD_SSH_KEY_NAME:-id_ed25519.pub}"

hcloud ssh-key describe "$SSH_KEY" >/dev/null
hcloud primary-ip describe "$PRIMARY_IPV4" >/dev/null

if hcloud server describe "$NAME" >/dev/null 2>&1; then
  echo "Server $NAME already exists."
else
  echo "Creating server $NAME..."
  hcloud server create \
    --name "$NAME" \
    --type "$TYPE" \
    --image "$IMAGE" \
    --location "$LOCATION" \
    --primary-ipv4 "$PRIMARY_IPV4" \
    --ssh-key "$SSH_KEY"
fi

echo
echo "=== Server ==="
hcloud server describe "$NAME"
echo
echo "=== Primary IP ==="
hcloud primary-ip describe "$PRIMARY_IPV4"
