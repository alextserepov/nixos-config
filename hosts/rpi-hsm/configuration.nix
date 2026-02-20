{ config, pkgs, lib, ... }:

{
  networking.hostName = "rpi-hsm";

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

  users.users.alextserepov = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBOQxe0N4f5NcLYVyUrhh7jw+SqS1HxcrFDdZ1BLukgU aleksandr.tserepov-savolainen@unikie.com"
    ];
  };

  users.groups.pkcs11-proxy = { };
  users.users.pkcs11-proxy = {
    isSystemUser = true;
    group = "pkcs11-proxy";
    extraGroups = [ "pcscd" ];
  };

  environment.systemPackages = with pkgs; [
    opensc
    openssl
    pkgs.pkcs11-proxy-tii
    usbutils
    pcsclite
    pcsc-tools
    gnutls
  ];

  services.pcscd.enable = true;
  services.pcscd.plugins = [ pkgs.ccid ];

#  hardware.enableAllHardware = lib.mkForce false;
#  boot.blacklistedKernelModules = [ "dw-hdmi" ];
#  boot.initrd.includeDefaultModules = false;
#  boot.initrd.kernelModules = lib.mkForce [ ];
#  boot.initrd.availableKernelModules = lib.mkForce [ ];
#  boot.kernelModules = lib.mkForce [ ];

  networking.firewall.allowedTCPPorts = [ 2345 ];

  systemd.tmpfiles.rules = [
    "d /var/lib/pkcs11-proxy 0750 pkcs11-proxy pkcs11-proxy - -"
  ];

  systemd.services.pkcs11-proxy = {
    description = "PKCS#11 Proxy (TLS-PSK)";
    after = [ "network.target" "pcscd.service" ];
    wants = [ "network.target" "pcscd.service" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      PKCS11_DAEMON_SOCKET = "tls://0.0.0.0:2345";
      PKCS11_PROXY_TLS_PSK_FILE = "/var/lib/pkcs11-proxy/psk.key";
    };
    preStart = ''
      if [ ! -s /var/lib/pkcs11-proxy/psk.key ]; then
        echo "Missing or empty /var/lib/pkcs11-proxy/psk.key (GnuTLS psktool format)." >&2
        echo "Create it with: psktool -u <identity> -p -f /var/lib/pkcs11-proxy/psk.key" >&2
        exit 1
      fi
    '';
    serviceConfig = {
      User = "pkcs11-proxy";
      Group = "pkcs11-proxy";
      SupplementaryGroups = [ "pcscd" ];
      ExecStart = "${pkgs.pkcs11-proxy-tii}/bin/pkcs11-daemon ${pkgs.opensc}/lib/opensc-pkcs11.so";
      Restart = "on-failure";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
    };
  };
}
