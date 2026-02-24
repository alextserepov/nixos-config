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
    slack
    hcloud
    polkit_gnome
    pavucontrol
    gnome-calendar
    wlogout
    networkmanagerapplet
    chromium
    gtk4.dev
    codex
    qutebrowser
    openssl
    openfortivpn
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
  };

  programs.bash = {
    shellAliases = {
      editor = "emacs -nw";
    };
    profileExtra = ''
      if command -v systemctl >/dev/null; then
      eval "$(systemctl --user show-environment | sed -n 's/^SSH_AUTH_SOCK=//p' | sed 's/^/export SSH_AUTH_SOCK=/')"
    fi
    '';
  };

  programs.kitty = {
    enable = true;

    settings = {
      scrollback_lines = 10000;
    };

    extraConfig = ''

      map ctrl+shift+j scroll_line_down
      map ctrl+shift+k scroll_line_up
      map ctrl+shift+u scroll_page_up
      map ctrl+shift+d scroll_page_down

      map ctrl+shift+c copy_to_clipboard
      map ctrl+shift+v paste_from_clipboard

    '';
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
      nix-mode
    ];
    extraConfig = ''
      (load-theme 'wheatgrass t)
    '';
  };

  services.ssh-agent = {
    enable = true;
    enableBashIntegration = true;
    socket = "ssh-agent";
  };
  
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.home-manager.enable = true;

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" "pkcs11" ];
  };

  systemd.user.services.polkit-gnome-agent = {
    Unit = {
      Description = "Polkit GNOME Authentication Agent";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
  systemd.user.services.ssh-agent.Service = {
    ExecStartPost = [
      ''${pkgs.systemd}/bin/systemctl --user set-environment SSH_AUTH_SOCK=%t/ssh-agent''
    ];
  };

}
