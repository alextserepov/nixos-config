{ config, pkgs, ... }:

{
  home.username = "alextserepov";
  home.homeDirectory = "/home/alextserepov";

  imports = [
    ./hyprland
  ];

  home.stateVersion = "25.11";

  wayland.windowManager.hyprland.settings.monitor = [
    "DP-5,1920x1080@60,0x0,1"
    "eDP-1,preferred,1920x0,1"
  ];


  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    tree
    google-chrome
    gcr
  ];

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export HISTCONTROL=ignoredups
      export HISTSIZE=10000
    '';
  };

  home.sessionVariables = {
    EDITOR = "emacs";
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
  };

  programs.bash.shellAliases = {
    editor = "emacs -nw";
  };

  programs.git = {
    enable = true;
    settings = {
      User = {
        name = "Aleksandr Tserepov-Savolainen";
	email = "aleksandr.tserepov-savolainen@unikie.com";
      };
      core.editor = "emacs -nw";
    };
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
  
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.home-manager.enable = true;

  services.gnome-keyring.enable = true;

}