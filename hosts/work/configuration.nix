{ config, pkgs, lib, ... }:

{
  powerManagement.enable = true;
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";

  time.timeZone = "Europe/Helsinki";
  i18n.defaultLocale = "en_US.UTF-8";

  # Carbon X1 Settings
  services.power-profiles-daemon.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
  services.logind.settings = {
    Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "ignore";
    };
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
    # Disable USB autosuspend for Logitech Bolt receiver (046d:c548)
    ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c548", TEST=="power/control", ATTR{power/control}="on"
  '';


#  services.udev.extraRules = ''
#    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
#  '';

  programs.git.enable = true;
  users.users.alextserepov = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
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
    hyprlock
    yubikey-manager
    pcsc-tools
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
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];


  nix.distributedBuilds = true;
  nix.settings.secret-key-files =
    lib.optionals (builtins.pathExists "/etc/nix/keys/arm-builder.secret") [
      "/etc/nix/keys/arm-builder.secret"
    ];
  system.activationScripts.armBuilderSigningKey = {
    text = ''
      install -d -m 0700 /etc/nix/keys
      if [ ! -f /etc/nix/keys/arm-builder.secret ]; then
        ${pkgs.nix}/bin/nix-store --generate-binary-cache-key arm-builder \
          /etc/nix/keys/arm-builder.secret \
          /etc/nix/keys/arm-builder.pub
        chmod 600 /etc/nix/keys/arm-builder.secret /etc/nix/keys/arm-builder.pub
      fi
    '';
  };

  system.activationScripts.armBuilderSshKey = {
    text = ''
      install -d -m 0700 /etc/nix/ssh
      if [ ! -f /etc/nix/ssh/arm-builder ]; then
        ssh-keygen -t ed25519 -N "" -f /etc/nix/ssh/arm-builder
        chmod 600 /etc/nix/ssh/arm-builder /etc/nix/ssh/arm-builder.pub
      fi
    '';
  };

  nix.buildMachines = [
    {
      hostName = "hetz.ppclabz.net";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      sshUser = "alextserepov";
      maxJobs = 4;          # tune per machine
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" ];
    }
    {
      hostName = "arm-builder.ppclabz.net";
      system = "aarch64-linux";
      protocol = "ssh-ng";
      sshUser = "alextserepov";
      sshKey = "/etc/nix/ssh/arm-builder";
      maxJobs = 4;
      supportedFeatures = [ "big-parallel" ];
    }
  ];

  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  programs.ssh.extraConfig = ''
    Host arm-builder.ppclabz.net
      User alextserepov
      IdentityFile /etc/nix/ssh/arm-builder
      UserKnownHostsFile /etc/ssh/ssh_known_hosts.d/arm-builder
      StrictHostKeyChecking no
  '';


  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Force the Intel SOF card to use the "Speaker" HiFi profile by default
  environment.etc."wireplumber/main.lua.d/70-default-speaker-profile.lua".text = ''
    rule = {
      matches = {
        {
          { "device.name", "matches", "alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic" },
        },
      },
      apply_properties = {
        ["device.profile"] = "HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)",
      },
    }
  '';

  # Yubikey stuff
  services.pcscd.enable = true;
  
}
