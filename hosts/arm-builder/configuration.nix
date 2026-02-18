{ config, pkgs, ... }:
{
  networking.hostName = "arm-builder";
  networking.useDHCP = true;
  networking.firewall.allowPing = true;

  services.openssh.enable = true;

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  system.stateVersion = "25.11";
}
