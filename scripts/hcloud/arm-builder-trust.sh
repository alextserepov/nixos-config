#!/usr/bin/env bash
set -euo pipefail

HOST="${HOST:-arm-builder.ppclabz.net}"

mkdir -p ~/.ssh
touch ~/.ssh/known_hosts

ssh-keygen -R "$HOST" >/dev/null 2>&1 || true
ssh-keyscan -t ed25519 "$HOST" >> ~/.ssh/known_hosts

echo "Added $HOST to ~/.ssh/known_hosts"
