{ config, pkgs, ... }:
{
  networking.hostName = "arm-builder";

  # THIS is enough for Hetzner Cloud
  networking.useDHCP = true;

  services.openssh.enable = true;

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # Ensure your user exists
  users.users.alextserepov = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBOQxe0N4f5NcLYVyUrhh7jw+SqS1HxcrFDdZ1BLukgU aleksandr.tserepov-savolainen@unikie.com"
    ];
  };
  

  services.xserver.enable = false;

  # builder-ish defaults
  nix.settings = {
    "max-jobs" = "auto";
    cores = 0;
  };

  # keep it lean
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  system.stateVersion = "25.11";
}
