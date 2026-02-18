#!/usr/bin/env bash
set -euo pipefail

HOST="arm-builder.ppclabz.net"   # once your DNS is set
# or: HOST="<ip>" until DNS is ready

nixos-rebuild switch \
  --flake ".#arm-builder" \
  --target-host "root@${HOST}" \
  --use-remote-sudo
