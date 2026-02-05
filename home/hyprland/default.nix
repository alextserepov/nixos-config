{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    kitty
    waybar
    wofi
    mako
  ];

  wayland.windowManager.hyprland.enable = true;

  imports = [
    ./settings.nix
  ];

  programs.waybar.enable = true;
  services.mako.enable = true;
}
