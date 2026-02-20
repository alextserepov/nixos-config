#!/usr/bin/env bash
set -euo pipefail

: "${HCLOUD_TOKEN:?Need HCLOUD_TOKEN set}"

NAME="${HCLOUD_SERVER_NAME:-ubuntu-arm-builder}"
SSH_USER="${SSH_USER:-root}"
BUILDER_USER="${BUILDER_USER:-alextserepov}"
SSH_WAIT_SECONDS="${SSH_WAIT_SECONDS:-240}"

if [[ -n "${HCLOUD_SSH_IDENTITY:-}" ]]; then
  SSH_IDENTITY="$HCLOUD_SSH_IDENTITY"
elif [[ "${EUID:-$(id -u)}" -eq 0 && -n "${SUDO_USER:-}" ]]; then
  SSH_IDENTITY="/home/${SUDO_USER}/.ssh/id_ed25519"
else
  SSH_IDENTITY="$HOME/.ssh/id_ed25519"
fi

if [[ -n "${SSH_PUBLIC_KEY:-}" ]]; then
  PUBKEY="${SSH_PUBLIC_KEY}"
elif [[ -f "/etc/nix/ssh/arm-builder.pub" ]]; then
  PUBKEY="$(cat /etc/nix/ssh/arm-builder.pub)"
elif [[ "${EUID:-$(id -u)}" -eq 0 && -n "${SUDO_USER:-}" && -f "/home/${SUDO_USER}/.ssh/id_ed25519.pub" ]]; then
  PUBKEY="$(cat "/home/${SUDO_USER}/.ssh/id_ed25519.pub")"
elif [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
  PUBKEY="$(cat "$HOME/.ssh/id_ed25519.pub")"
else
  PUBKEY=""
fi

IP="$(hcloud server describe "$NAME" -o format='{{.PublicNet.IPv4.IP}}')"
if [[ -z "$IP" ]]; then
  echo "No public IPv4 found for $NAME."
  exit 1
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

echo "Waiting for SSH on $NAME ($IP) as ${SSH_USER}..."
if ! wait_for_ssh "$IP"; then
  echo "SSH not reachable on $NAME ($IP)."
  exit 1
fi

if [[ -n "$PUBKEY" ]]; then
  PUBKEY_B64="$(printf '%s' "$PUBKEY" | base64 -w0)"
else
  PUBKEY_B64=""
fi

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -o IdentitiesOnly=yes -o BatchMode=yes -i "$SSH_IDENTITY" \
  "${SSH_USER}@${IP}" \
  "BUILDER_USER='${BUILDER_USER}' PUBKEY_B64='${PUBKEY_B64}' bash -s" <<'REMOTE'
set -euo pipefail

if ! command -v curl >/dev/null; then
  apt-get update
  apt-get install -y curl xz-utils ca-certificates
fi

if ! command -v systemctl >/dev/null; then
  apt-get update
  apt-get install -y systemd
fi

if ! command -v sshd >/dev/null; then
  apt-get update
  apt-get install -y openssh-server
fi

systemctl enable --now ssh || true

if [[ -n "${BUILDER_USER}" && "${BUILDER_USER}" != "root" ]]; then
  if ! id -u "${BUILDER_USER}" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "${BUILDER_USER}"
    usermod -aG sudo "${BUILDER_USER}"
  fi

  if [[ -n "${PUBKEY_B64}" ]]; then
    PUBKEY="$(printf '%s' "${PUBKEY_B64}" | base64 -d)"
    install -d -m 0700 "/home/${BUILDER_USER}/.ssh"
    touch "/home/${BUILDER_USER}/.ssh/authorized_keys"
    if ! grep -Fq "${PUBKEY}" "/home/${BUILDER_USER}/.ssh/authorized_keys"; then
      echo "${PUBKEY}" >> "/home/${BUILDER_USER}/.ssh/authorized_keys"
    fi
    chmod 0600 "/home/${BUILDER_USER}/.ssh/authorized_keys"
    chown -R "${BUILDER_USER}:${BUILDER_USER}" "/home/${BUILDER_USER}/.ssh"
  fi

  echo "${BUILDER_USER} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${BUILDER_USER}"
  chmod 0440 "/etc/sudoers.d/${BUILDER_USER}"
fi

if ! command -v nix >/dev/null; then
  sh <(curl -L https://nixos.org/nix/install) --daemon
fi

ensure_conf() {
  local key="$1"
  local value="$2"
  if grep -qE "^${key} = " /etc/nix/nix.conf; then
    sed -i "s|^${key} = .*|${key} = ${value}|" /etc/nix/nix.conf
  else
    echo "${key} = ${value}" >> /etc/nix/nix.conf
  fi
}

touch /etc/nix/nix.conf
ensure_conf "experimental-features" "nix-command flakes"
ensure_conf "trusted-users" "root ${BUILDER_USER}"
ensure_conf "allowed-users" "root ${BUILDER_USER}"
ensure_conf "max-jobs" "auto"
ensure_conf "cores" "0"

systemctl enable --now nix-daemon
REMOTE

echo "Ubuntu Nix builder setup complete on $NAME ($IP)."
