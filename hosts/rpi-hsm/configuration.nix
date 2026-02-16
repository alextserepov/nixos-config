{ config, pkgs, lib, ... }:

{
  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
  };

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  time.timeZone = "Europe/Helsinki";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    opensc
    openssl
    pkgs.pkcs11-proxy-tii
    usbutils
    pcsclite
  ];

  services.pcscd.enable = true;
  services.pcscd.plugins = [ pkgs.ccid ];
}
