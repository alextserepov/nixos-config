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

  users.users.alextserepov = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBOQxe0N4f5NcLYVyUrhh7jw+SqS1HxcrFDdZ1BLukgU aleksandr.tserepov-savolainen@unikie.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMvERyCMpHvGpYCl+stqSF/8ITe/Nmr+mRPjAanwz5Up root@nixos"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBOQxe0N4f5NcLYVyUrhh7jw+SqS1HxcrFDdZ1BLukgU aleksandr.tserepov-savolainen@unikie.com"
  ];

  nix.settings = {
    "max-jobs" = "auto";
    cores = 0;
    trusted-users = [ "root" "alextserepov" ];
    allowed-users = [ "root" "alextserepov" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  system.stateVersion = "25.11";
}
