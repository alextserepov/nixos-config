{ config, pkgs, ... }:

{
  home.username = "alextserepov";
  home.homeDirectory = "/home/alextserepov";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    tree
    google-chrome
  ];

  programs.git = {
    enable = true;
    userName = "Aleksandr Tserepov-Savolainen";
    userEmail = "aleksandr.tserepov-savolainen@unikie.com";
  };

  programs.home-manager.enable = true;
}