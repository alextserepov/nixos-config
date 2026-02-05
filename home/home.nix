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

  programs.bash = {
    enable = true;
    bashrcExtra = '';
      export HISTCONTROL=ignoredups
      export HISTSIZE=10000
      export EDITOR=emacs
      '';
  };

  programs.git = {
    enable = true;
    userName = "Aleksandr Tserepov-Savolainen";
    userEmail = "aleksandr.tserepov-savolainen@unikie.com";
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      magit
      use-package
      eglot
      company
      flycheck
    ];
  };

  programs.home-manager.enable = true;
}