{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    kitty
    waybar
    wofi
    mako
    grim
    slurp
    wl-clipboard
    cosmic-term
  ];

  wayland.windowManager.hyprland.enable = true;

  imports = [
    ./settings.nix
    ./keybindings.nix
    ./waybar.nix
  ];

  programs.waybar.enable = true;
  services.mako.enable = true;
}
