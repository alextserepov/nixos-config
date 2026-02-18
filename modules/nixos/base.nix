{ config, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  time.timeZone = "Europe/Helsinki";

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  users.users.alextserepov = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBOQxe0N4f5NcLYVyUrhh7jw+SqS1HxcrFDdZ1BLukgU aleksandr.tserepov-savolainen@unikie.com"
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "yes";
    };
  };

  # sensible defaults
  networking.firewall.enable = true;
  services.openssh.openFirewall = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    age
    sops
    age-plugin-yubikey
  ];
}
