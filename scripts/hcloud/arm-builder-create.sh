#!/usr/bin/env bash
set -euo pipefail

: "${HCLOUD_TOKEN:?Need HCLOUD_TOKEN set}"
LOCATION="${HCLOUD_LOCATION:-hel1}"
NAME="arm-builder"
TYPE="cax21"
IMAGE="ubuntu-24.04"

hcloud server create \
  --name "$NAME" \
  --type "$TYPE" \
  --image "$IMAGE" \
  --location "$LOCATION" \
  --primary-ipv4 "arm-builder-ip1" \
  --ssh-key "id_ed25519.pub"

hcloud server info "$NAME"
