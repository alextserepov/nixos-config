{ config, pkgs, lib, ... }:

{
  networking.hostName = "rpi4";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  time.timeZone = "Europe/Helsinki";
  i18n.defaultLocale = "en_US.UTF-8";

  # Required by NixOS.
  system.stateVersion = "25.11";

  # sd-image-aarch64.nix already sets extlinux, but keep it explicit here.
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.networkmanager.enable = true;

  # Pre-provision Wi-Fi (stored in plaintext in the Nix store / /etc).
  environment.etc."NetworkManager/system-connections/DNA-WIFI-E4C4.nmconnection" = {
    mode = "0600";
    text = ''
      [connection]
      id=DNA-WIFI-E4C4
      type=wifi
      autoconnect=true

      [wifi]
      mode=infrastructure
      ssid=DNA-WIFI-E4C4

      [wifi-security]
      key-mgmt=wpa-psk
      psk=qweqwe123456

      [ipv4]
      method=auto

      [ipv6]
      method=auto
    '';
  };

  users.users.alextserepov = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    # "Any password" requested; change it later with `passwd`.
    initialPassword = "nixos";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBOQxe0N4f5NcLYVyUrhh7jw+SqS1HxcrFDdZ1BLukgU aleksandr.tserepov-savolainen@unikie.com"
    ];
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "alextserepov";

  # Audio for GNOME.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  hardware.opengl.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    htop
    usbutils
    # Google Chrome isn't available on aarch64-linux; use Chromium on the Pi.
    chromium
  ];
}

