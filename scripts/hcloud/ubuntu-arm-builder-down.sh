#!/usr/bin/env bash
set -euo pipefail
: "${HCLOUD_TOKEN:?Need HCLOUD_TOKEN set}"

NAME="${HCLOUD_SERVER_NAME:-ubuntu-arm-builder}"

if hcloud server describe "$NAME" >/dev/null 2>&1; then
  hcloud server delete "$NAME"
  echo "Deleted server $NAME"
else
  echo "Server $NAME does not exist."
fi
