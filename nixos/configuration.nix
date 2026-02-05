{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";

  time.timeZone = "Europe/Helsinki";
  i18n.defaultLocale = "en_US.UTF-8";

  # Carbon X1 Settings
  services.power-profiles-daemon.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
  services.logind.lidSwitch = "suspend";
  services.logind.lidSwitchExternalPower = "lock";
  services.xserver.libinput = {
    enable = true;
    mouse.accelProfile = "flat";
    touchpad.naturalScrolling = true;
  };
  services.fwupd.enable = true;

  networking.networkmanager.enable = true;

  programs.git.enable = true;
  users.users.alextserepov = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.bashInteractive;
  };

  environment.systemPackages = with pkgs; [
    emacs
    wget
    curl
    htop
    pciutils
    usbutils
  ];

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
}