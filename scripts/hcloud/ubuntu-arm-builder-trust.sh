#!/usr/bin/env bash
set -euo pipefail

HOST="${HOST:-arm-builder.ppclabz.net}"
KNOWN_HOSTS_SYSTEM="${KNOWN_HOSTS_SYSTEM:-/etc/ssh/ssh_known_hosts.d/arm-builder}"
if [[ "${EUID:-$(id -u)}" -eq 0 && -n "${SUDO_USER:-}" ]]; then
  SSH_USER="${SSH_USER:-$SUDO_USER}"
  USER_HOME="/home/${SUDO_USER}"
else
  SSH_USER="${SSH_USER:-alextserepov}"
  USER_HOME="$HOME"
fi
KNOWN_HOSTS_USER="${KNOWN_HOSTS_USER:-$USER_HOME/.ssh/known_hosts}"
if [[ -n "${HCLOUD_SSH_IDENTITY:-}" ]]; then
  SSH_IDENTITY="$HCLOUD_SSH_IDENTITY"
elif [[ -n "${SUDO_USER:-}" && -f "/home/${SUDO_USER}/.ssh/id_ed25519" ]]; then
  SSH_IDENTITY="/home/${SUDO_USER}/.ssh/id_ed25519"
else
  SSH_IDENTITY="$USER_HOME/.ssh/id_ed25519"
fi

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

# Ensure local builder key is usable for manual SSH.
if [[ -f /etc/nix/ssh/arm-builder ]]; then
  sudo chmod 700 /etc/nix/ssh
  sudo chown root:root /etc/nix/ssh/arm-builder
  sudo chmod 600 /etc/nix/ssh/arm-builder

  mkdir -p "$USER_HOME/.ssh"
  sudo install -m 600 /etc/nix/ssh/arm-builder "$USER_HOME/.ssh/arm-builder"
  sudo chown "$(id -u "${SSH_USER}")":"$(id -g "${SSH_USER}")" "$USER_HOME/.ssh/arm-builder"
  echo "Installed local copy of /etc/nix/ssh/arm-builder to $USER_HOME/.ssh/arm-builder"
fi

# Install SSH public key on the remote builder (if present locally).
if [[ -f /etc/nix/ssh/arm-builder.pub ]]; then
  if [[ "${EUID:-$(id -u)}" -ne 0 ]] && ! sudo -n true 2>/dev/null; then
    echo "Need sudo to read /etc/nix/ssh/arm-builder.pub. Re-run with: sudo nix run .#ubuntu-arm-builder-trust --builders ''"
    exit 1
  fi
  PUBKEY="$(sudo cat /etc/nix/ssh/arm-builder.pub)"
  ssh -i "$SSH_IDENTITY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    "${SSH_USER}@${HOST}" \
    "mkdir -p ~/.ssh && chmod 700 ~/.ssh && \
      grep -Fq '${PUBKEY}' ~/.ssh/authorized_keys 2>/dev/null || echo '${PUBKEY}' >> ~/.ssh/authorized_keys && \
      chmod 600 ~/.ssh/authorized_keys"
  echo "Installed /etc/nix/ssh/arm-builder.pub on ${SSH_USER}@${HOST}"
fi

# Trust local signing key on the remote builder (if present).
if [[ -f /etc/nix/keys/arm-builder.pub ]]; then
  echo "Copying signing key to $HOST..."
  scp -i "$SSH_IDENTITY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    /etc/nix/keys/arm-builder.pub "$HOST:/tmp/arm-builder.pub"
  if ssh -i "$SSH_IDENTITY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    "${SSH_USER}@${HOST}" "sudo -n true" >/dev/null 2>&1; then
    ssh -i "$SSH_IDENTITY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
      "${SSH_USER}@${HOST}" \
      "sudo sh -c 'key=\"arm-builder:\$(cat /tmp/arm-builder.pub)\"; \
        touch /etc/nix/nix.conf; \
        grep -qF \"\$key\" /etc/nix/nix.conf || echo \"trusted-public-keys = \$key\" >> /etc/nix/nix.conf; \
        systemctl restart nix-daemon'"
    echo "Added signing key to $HOST /etc/nix/nix.conf"
  elif [[ -n "${SSH_SUDO_PASSWORD:-}" ]]; then
    printf '%s\n' "$SSH_SUDO_PASSWORD" | \
      ssh -i "$SSH_IDENTITY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        "${SSH_USER}@${HOST}" \
        "sudo -S sh -c 'key=\"arm-builder:\$(cat /tmp/arm-builder.pub)\"; \
          touch /etc/nix/nix.conf; \
          grep -qF \"\$key\" /etc/nix/nix.conf || echo \"trusted-public-keys = \$key\" >> /etc/nix/nix.conf; \
          systemctl restart nix-daemon'"
    echo "Added signing key to $HOST /etc/nix/nix.conf"
  else
    echo "Could not add signing key on $HOST (sudo needs a password)."
    echo "Re-run with SSH_SUDO_PASSWORD=... or add the key manually."
  fi
fi
