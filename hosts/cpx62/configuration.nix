{ config, pkgs, ... }:
{

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  networking.hostName = "cpx62";

  # If this is a server, you probably don’t want a GUI
  services.xserver.enable = false;

  # Make sure SSH is on (base already enables it)
  services.openssh.enable = true;

  # Optional: if you want to build for other machines, keep plenty of store space
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Helpful for builders:
  nix.settings = {
    max-jobs = "auto";
    cores = 0; # use all
  };
}
