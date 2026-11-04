{ pkgs, ... }:

let
  theme = {
    bg = "#181818";
    surface = "#1b1b1b";
    chrome = "#5f676a";
    fg = "#c4c4c4";
    muted = "#6e6e6e";
    accent = "#7cb987";
  };
in
{
  gtk = {
    enable = true;
    colorScheme = "dark";

    font = {
      name = "Noto Sans";
      size = 10;
    };

    gtk3.theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };

  wayland.windowManager.sway.config = {
    fonts = {
      names = [ "Noto Sans" ];
      size = 10.0;
    };

    colors.focused = {
      border = theme.chrome;
      background = theme.chrome;
      text = theme.fg;
      indicator = theme.accent;
      childBorder = theme.chrome;
    };

    bars = [
      {
        position = "bottom";
        trayOutput = "primary";
        workspaceButtons = true;
        workspaceNumbers = true;

        fonts = {
          names = [ "JetBrainsMono Nerd Font" ];
          size = 10.0;
        };

        colors = {
          background = theme.bg;
          statusline = theme.fg;
          separator = theme.muted;

          focusedWorkspace = {
            border = theme.chrome;
            background = theme.chrome;
            text = "#ffffff";
          };

          activeWorkspace = {
            border = theme.chrome;
            background = theme.surface;
            text = theme.fg;
          };

          inactiveWorkspace = {
            border = theme.surface;
            background = theme.surface;
            text = theme.muted;
          };
        };
      }
    ];
  };
}
