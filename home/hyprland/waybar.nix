{ pkgs, ... }:
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
        modules-right = [ "network" "bluetooth" "pulseaudio" "custom/bt-kbd" "custom/bt-mouse" "battery" "tray" ];

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

        # Bluetooth keyboard battery via UPower (BlueZ).
        # Your device paths look like:
        #   /org/freedesktop/UPower/devices/keyboard_dev_XX_XX_...
        "custom/bt-kbd" = {
          interval = 60;
          return-type = "json";
          exec = ''
            upower="${pkgs.upower}/bin/upower"
            dev="$($upower -e | ${pkgs.gnugrep}/bin/grep -E '/org/freedesktop/UPower/devices/keyboard_dev_' | ${pkgs.coreutils}/bin/head -n1)"
            if [ -z "$dev" ]; then
              echo '{"text":"󰌌 --","tooltip":"No keyboard_dev_* found via UPower"}'
              exit 0
            fi
            pct="$($upower -i "$dev" | ${pkgs.gawk}/bin/awk -F': *' '/percentage/ {print $2}' | ${pkgs.coreutils}/bin/tr -d ' ')"
            model="$($upower -i "$dev" | ${pkgs.gawk}/bin/awk -F': *' '/model/ {print $2}' | ${pkgs.gnused}/bin/sed 's/"/\\\"/g')"
            echo "{\"text\":\"󰌌 $pct\",\"tooltip\":\"$model\\n$dev\"}"
          '';
        };

        # Bluetooth mouse battery via UPower (BlueZ).
        # Your device paths look like:
        #   /org/freedesktop/UPower/devices/mouse_dev_XX_XX_...
        "custom/bt-mouse" = {
          interval = 60;
          return-type = "json";
          exec = ''
            upower="${pkgs.upower}/bin/upower"
            dev="$($upower -e | ${pkgs.gnugrep}/bin/grep -E '/org/freedesktop/UPower/devices/mouse_dev_' | ${pkgs.coreutils}/bin/head -n1)"
            if [ -z "$dev" ]; then
              echo '{"text":"󰍽 --","tooltip":"No mouse_dev_* found via UPower"}'
              exit 0
            fi
            pct="$($upower -i "$dev" | ${pkgs.gawk}/bin/awk -F': *' '/percentage/ {print $2}' | ${pkgs.coreutils}/bin/tr -d ' ')"
            model="$($upower -i "$dev" | ${pkgs.gawk}/bin/awk -F': *' '/model/ {print $2}' | ${pkgs.gnused}/bin/sed 's/"/\\\"/g')"
            echo "{\"text\":\"󰍽 $pct\",\"tooltip\":\"$model\\n$dev\"}"
          '';
        };

        battery = {
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰂄 {capacity}%";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          tooltip = true;
          on-click = "kitty -e ${pkgs.upower}/bin/upower -i $(${pkgs.upower}/bin/upower -e | ${pkgs.gnugrep}/bin/grep BAT)";
        };

        "hyprland/workspaces" = {
          format = "{icon} {id}";
          persistent-workspaces = { "*" = [ 1 2 3 4 5 6 7 8 9 0 ]; };
          format-icons = {
            empty = "";
            default = "";
            active = "";
            urgent = "";
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
      #workspaces, #clock, #network, #bluetooth, #pulseaudio, #custom-bt-kbd, #custom-bt-mouse, #battery, #tray, #window {
        background: rgba(255, 255, 255, 0.08);
        border-radius: 999px;
        padding: 4px 10px;
        margin: 2px 4px;
      }

      /* Workspaces: round buttons */
      #workspaces button {
        background: rgba(255, 255, 255, 0.18);
        border-radius: 999px;
        padding: 2px 8px;
        margin: 0 2px;
      }

      #workspaces button.empty {
        background: transparent;
      }

      #workspaces button.urgent {
        background: rgba(255, 80, 80, 0.35);
      }

      #workspaces button.active {
        background: rgba(80, 200, 120, 0.35);
      }

      /* Window title should not stretch too much */
      #window {
        padding-left: 12px;
        padding-right: 12px;
      }
    '';
  };
}
