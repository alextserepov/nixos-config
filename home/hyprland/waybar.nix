{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        margin-top = 8;
        margin-left = 10;
        margin-right = 10;
        spacing = 8;

        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "network" "bluetooth" "pulseaudio" "battery" "tray" ];

        clock = {
          format = "{:%a %d.%m  %H:%M}";
	  tooltip-format = "{:%A %d %B %Y\n%H:%M:%S}";
	  on-click = "gnome-calendar";
	  on-click-right = "kitty -e cal -3";
        };

        network = {
          format-wifi = " {signalStrength}%";
          format-ethernet = "󰈁 {ifname}";
          format-disconnected = "󰖪";
          tooltip = true;
          on-click = "kitty -e nmtui";
          on-click-right = "nm-connection-editor";
        };

        bluetooth = {
          format = "";
          format-connected = " {num_connections}";
          tooltip = true;
          on-click = "blueman-manager";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 muted";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
          scroll-step = 5;
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-right = "pavucontrol";
        };

        battery = {
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰂄 {capacity}%";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          tooltip = true;
          on-click = "kitty -e upower -i $(upower -e | grep BAT)";
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "default" = "";
            "active" = "";
            "urgent" = "";
          };
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrains Mono";
        font-size: 12px;
        min-height: 0;
	color: rgba(255, 255, 255, 0.92);
      }

      window#waybar {
        background: rgba(20, 20, 20, 0.35);
        border-radius: 14px;
        padding: 6px 10px;
      }

      /* Make each module look like a pill instead of a box */
      #workspaces, #clock, #network, #bluetooth, #pulseaudio, #battery, #tray, #window {
        background: rgba(255, 255, 255, 0.08);
        border-radius: 999px;
        padding: 4px 10px;
        margin: 2px 4px;
      }

      /* Workspaces: round buttons */
      #workspaces button {
        background: transparent;
        border-radius: 999px;
        padding: 2px 8px;
        margin: 0 2px;
      }

      #workspaces button.active {
        background: rgba(255, 255, 255, 0.18);
      }

      #workspaces button.urgent {
        background: rgba(255, 80, 80, 0.35);
      }

      /* Window title should not stretch too much */
      #window {
        padding-left: 12px;
        padding-right: 12px;
      }
    '';
  };
}
