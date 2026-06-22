
{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 24;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [
          "custom/bt-kbd"
          "custom/bt-mouse"
          "cpu"
          "memory"
          "temperature"
          "pulseaudio"
          "network"
          "battery"
          "tray"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
        };

        clock = {
          format = "{:%a %H:%M}";
        };

        cpu = {
          format = " {usage}%";
        };

        memory = {
          format = "󰍛 {percentage}%";
        };

        temperature = {
          format = " {temperatureC}°C";
        };

        network = {
          format-wifi = "";
          format-ethernet = "󰈀";
          format-disconnected = "󰖪";
        };

        pulseaudio = {
          format = " {volume}%";
          format-muted = "󰝟";
        };

        battery = {
          format = "{capacity}% {icon}";
          format-icons = [ "" "" "" "" "" ];
        };

        "custom/bt-kbd" = {
          interval = 60;
          return-type = "json";
          exec = ''
            upower="${pkgs.upower}/bin/upower"
            dev="$($upower -e | ${pkgs.gnugrep}/bin/grep keyboard_dev_ | ${pkgs.coreutils}/bin/head -n1)"
            if [ -z "$dev" ]; then
              echo '{"text":"󰌌 --"}'
              exit 0
            fi
            pct="$($upower -i "$dev" | ${pkgs.gawk}/bin/awk -F': *' '/percentage/ {print $2}' | ${pkgs.coreutils}/bin/tr -d ' ')"
            echo "{\"text\":\"󰌌 $pct\"}"
          '';
        };

        "custom/bt-mouse" = {
          interval = 60;
          return-type = "json";
          exec = ''
            upower="${pkgs.upower}/bin/upower"
            dev="$($upower -e | ${pkgs.gnugrep}/bin/grep mouse_dev_ | ${pkgs.coreutils}/bin/head -n1)"
            if [ -z "$dev" ]; then
              echo '{"text":"󰍽 --"}'
              exit 0
            fi
            pct="$($upower -i "$dev" | ${pkgs.gawk}/bin/awk -F': *' '/percentage/ {print $2}' | ${pkgs.coreutils}/bin/tr -d ' ')"
            echo "{\"text\":\"󰍽 $pct\"}"
          '';
        };
      };
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 12px;
        border: none;
        box-shadow: none;
        min-height: 0;
      }

      /* bar */
      #waybar {
        background: rgba(30,30,30,0.90);
        color: #e5e5e5;
      }

      /* kill any "pill" styling from previous CSS/theme */
      #waybar .module,
      #waybar .module > box,
      #waybar label,
      #waybar button,
      #waybar image {
        background: transparent;
        border-radius: 0;
        box-shadow: none;
        padding-top: 0;
        padding-bottom: 0;
      }

      /* flat blocks / segments */
      #waybar .module {
        padding: 0 10px;
        margin: 0;
        border-right: 1px solid rgba(255,255,255,0.08);
      }

      #waybar .module:last-child {
        border-right: none;
      }

      /* workspaces */
      #workspaces button {
        padding: 0 6px;
        margin: 0;
        border-radius: 0;
        background: transparent;
        color: #ffffff;
      }

      #workspaces button.active {
        background: rgba(58, 130, 246, 0.90);
        color: #ffffff;
      }

      /* explicitly override common modules (some themes target these IDs) */
      #clock,
      #custom-bt-kbd,
      #custom-bt-mouse,
      #pulseaudio,
      #network,
      #battery,
      #tray,
      #cpu,
      #memory,
      #temperature {
        background: transparent;
        border-radius: 0;
        box-shadow: none;
      }

      /* tray icons sometimes get a rounded background from GTK theme */
      #tray > .passive,
      #tray > .needs-attention,
      #tray > widget,
      #tray image {
        background: transparent;
        border-radius: 0;
        box-shadow: none;
      }
    '';
  };
}
