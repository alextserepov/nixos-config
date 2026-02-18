{ config, lib, modulesPath, ... }:
{
  # Hetzner Cloud ARM runs as a QEMU guest; ensure virtio modules are in initrd.
  imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];

  # Make sure we get output on Hetzner's serial console and VGA (if present).
  boot.kernelParams = [ "console=ttyAMA0,115200n8" "console=tty0" ];
}
