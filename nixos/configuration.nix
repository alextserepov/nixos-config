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
    touchpad.naturalScrolling = false;
  };
  services.fwupd.enable = true;

  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  hardware.bluetooth.settings = {
    General = {
      FastConnectable = true;
      ReconnectAttempts = 7;
      ReconnectIntervals = "1,2,3";
    };
  };

  services.libinput.enable = true;
  services.libinput.touchpad = {
    naturalScrolling = true;
    tapping = true;
    clickMethod = "clickfinger";
    disableWhileTyping = true;
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
  '';

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
    wl-clipboard
    grim
    slurp
  ];

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main = {
	  ejectcd = "delete";
	};
      };
    };
  };

  programs.hyprland.enable = true;
  
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];

  fonts.packages = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];

}