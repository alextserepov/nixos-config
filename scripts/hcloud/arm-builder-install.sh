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

detect_disk() {
  local disks primary
  disks="$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -o ConnectTimeout=5 -o BatchMode=yes -o IdentitiesOnly=yes -i "$SSH_IDENTITY" \
    "root@${IP}" \
    "lsblk -dn -o NAME,TYPE | awk '\$2==\"disk\"{print \$1}'")" || return 1
  primary="$(printf '%s\n' "$disks" | awk '
    $1=="nvme0n1" {print; found=1}
    END {if (!found) print ""}' | head -n1)"
  if [[ -z "$primary" ]]; then
    primary="$(printf '%s\n' "$disks" | awk '
      $1=="vda" {print; found=1}
      END {if (!found) print ""}' | head -n1)"
  fi
  if [[ -z "$primary" ]]; then
    primary="$(printf '%s\n' "$disks" | awk '
      $1=="sda" {print; found=1}
      END {if (!found) print ""}' | head -n1)"
  fi
  if [[ -z "$primary" ]]; then
    primary="$(printf '%s\n' "$disks" | head -n1)"
  fi
  if [[ -z "$primary" ]]; then
    return 1
  fi
  echo "/dev/${primary}"
}

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

if [[ -z "${DISK_DEVICE:-}" ]]; then
  if DISK_DEVICE="$(detect_disk)"; then
    export DISK_DEVICE
    echo "Detected install disk: ${DISK_DEVICE}"
  else
    echo "Failed to detect install disk in rescue."
    exit 1
  fi
else
  echo "Using DISK_DEVICE=${DISK_DEVICE}"
fi

KEEP_RESCUE_ON_FAILURE="${KEEP_RESCUE_ON_FAILURE:-0}"
RESCUE_CLEANED=0
cleanup_rescue() {
  if [[ "$RESCUE_CLEANED" -eq 1 ]]; then
    return 0
  fi
  if [[ "$KEEP_RESCUE_ON_FAILURE" -eq 1 ]]; then
    return 0
  fi
  hcloud server disable-rescue "$NAME" || true
  hcloud server reboot "$NAME" || true
  RESCUE_CLEANED=1
}
trap cleanup_rescue EXIT

# Run from repo root:
if ! nix run github:nix-community/nixos-anywhere -- \
  --flake ".#arm-builder" \
  --build-on remote \
  --debug \
  -i "$SSH_IDENTITY" \
  --ssh-option "IdentitiesOnly=yes" \
  --ssh-option "UserKnownHostsFile=/dev/null" \
  --ssh-option "StrictHostKeyChecking=no" \
  --ssh-option "BatchMode=yes" \
  --ssh-option "ConnectionAttempts=20" \
  "root@${IP}"; then
  echo "nixos-anywhere failed for $NAME. Rescue will be disabled unless KEEP_RESCUE_ON_FAILURE=1."
  exit 1
fi

cleanup_rescue
trap - EXIT

if ! wait_for_rescue_status "false"; then
  echo "Rescue did not disable within ${RESCUE_WAIT_SECONDS}s for $NAME."
  exit 1
fi
