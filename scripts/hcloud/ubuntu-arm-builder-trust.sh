#!/usr/bin/env bash
set -euo pipefail

HOST="${HOST:-arm-builder.ppclabz.net}"
KNOWN_HOSTS_SYSTEM="${KNOWN_HOSTS_SYSTEM:-/etc/ssh/ssh_known_hosts.d/arm-builder}"
KNOWN_HOSTS_USER="${KNOWN_HOSTS_USER:-$HOME/.ssh/known_hosts}"

mkdir -p "$(dirname "$KNOWN_HOSTS_USER")"
touch "$KNOWN_HOSTS_USER"

ssh-keygen -R "$HOST" >/dev/null 2>&1 || true
ssh-keyscan -t ed25519 "$HOST" >> "$KNOWN_HOSTS_USER"

sudo install -d -m 0755 "$(dirname "$KNOWN_HOSTS_SYSTEM")"
sudo touch "$KNOWN_HOSTS_SYSTEM"
sudo ssh-keygen -R "$HOST" -f "$KNOWN_HOSTS_SYSTEM" >/dev/null 2>&1 || true
ssh-keyscan -t ed25519 "$HOST" | sudo tee -a "$KNOWN_HOSTS_SYSTEM" >/dev/null
echo "Added $HOST to $KNOWN_HOSTS_SYSTEM"

echo "Added $HOST to $KNOWN_HOSTS_USER"
