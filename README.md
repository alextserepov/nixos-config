# nixos-config-builder

NixOS + Home Manager flake with Hetzner Cloud builder automation.

## Features

- Multiple NixOS host configurations via `mkHost`:
  - `work` (x86_64)
  - `cpx62` (x86_64)
- Dedicated ARM builder host:
  - `arm-builder` (aarch64) using `disko` for disk layout
- Raspberry Pi HSM image:
  - `rpi-hsm` (aarch64) with Raspberry Pi 4 hardware module
  - Custom overlay for the TIIUAE fork of `pkcs11-proxy`
- Home Manager integration for the primary user (`alextserepov`) via `home/home.nix`
- Hetzner Cloud automation scripts packaged as flake `packages` and `apps`:
  - NixOS builder lifecycle: `arm-builder-up`, `arm-builder-install`, `arm-builder-rescue`, `arm-builder-up-install`, `arm-builder-deploy`, `arm-builder-trust`, `arm-builder-down`
  - Ubuntu builder lifecycle: `ubuntu-arm-builder-up`, `ubuntu-arm-builder-setup`, `ubuntu-arm-builder-up-setup`, `ubuntu-arm-builder-trust`, `ubuntu-arm-builder-down`
  - Alias: `nix-builder-down` -> `arm-builder-down`

## Ubuntu ARM builder setup (Hetzner Cloud)

This creates a Hetzner ARM VM, installs Nix, and configures it as a remote builder.

### Prereqs

- `hcloud` CLI configured (token or `HCLOUD_TOKEN`)
- A Hetzner Primary IPv4 resource (default name: `arm-builder-ip1`)
- A Hetzner SSH key resource (default name: `id_ed25519.pub`)
- On your local machine, a builder SSH key at `/etc/nix/ssh/arm-builder.pub` (used to authorize SSH on the builder)

### One-shot setup

```
export HCLOUD_TOKEN=...   # required
sudo nix run .#ubuntu-arm-builder-up-setup --builders ''
```

This runs:
- `ubuntu-arm-builder-up` (create VM)
- `ubuntu-arm-builder-setup` (install Nix, create builder user, configure nix.conf)

### Optional: set or override defaults

The scripts accept env vars to override defaults:

- `HCLOUD_SERVER_NAME` (default `ubuntu-arm-builder`)
- `HCLOUD_SERVER_TYPE` (default `cax41`)
- `HCLOUD_BOOT_IMAGE` (default `ubuntu-24.04`)
- `HCLOUD_LOCATION` (default `hel1`)
- `HCLOUD_SSH_KEY_NAME` (default `id_ed25519.pub`)
- `HCLOUD_PRIMARY_IPV4_NAME` (default `arm-builder-ip1`)
- `SSH_USER` (default `root`)
- `BUILDER_USER` (default `alextserepov`)
- `HCLOUD_SSH_IDENTITY` (path to local SSH key used to bootstrap the VM)
- `SSH_PUBLIC_KEY` (explicit public key to install on the builder)

Example:

```
export HCLOUD_TOKEN=...
export HCLOUD_SERVER_NAME=ubuntu-arm-builder
export HCLOUD_PRIMARY_IPV4_NAME=arm-builder-ip1
sudo nix run .#ubuntu-arm-builder-up-setup --builders ''
```

### Trust and SSH

To keep builder keys in sync (authorized keys + known hosts), run:

```
sudo nix run .#ubuntu-arm-builder-trust --builders ''
```

This updates local known_hosts and pushes `/etc/nix/ssh/arm-builder.pub` to the builder.

## NixOS ARM builder setup (Hetzner Cloud)

For the NixOS-based builder, use the `arm-builder-*` scripts instead of the Ubuntu ones:

- `arm-builder-up-install` (provision + install NixOS)
- `arm-builder-trust` (sync SSH keys + signing key)

## Build targets

- NixOS configs: `.#nixosConfigurations.<host>`
- Raspberry Pi image: `.#nixosConfigurations.rpi-hsm.config.system.build.sdImage`

## Notes

- The flake pins `nixpkgs` and `home-manager` to release `25.11`.
- `nix-builder-down` is an alias for `arm-builder-down`.
