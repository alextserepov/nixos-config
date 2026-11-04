{ pkgs, lib, ... }:

{
  wayland.windowManager.sway = {
    enable = true;

    config = {
      modifier = "Mod4";
      terminal = "${pkgs.cosmic-term}/bin/cosmic-term";

      startup = [
        {
	  command = "${pkgs.autotiling-rs}/bin/autotiling-rs";
	  always = false;
        }
      ];

      keybindings = lib.mkOptionDefault {
      	"Mod4+q" = "kill";
	"Mod4+w" = "exec ${pkgs.hyprlock}/bin/hyprlock";
	"Mod4+space" = "layout toggle all";
	"Mod4+Escape" = "exec ${pkgs.wlogout}/bin/wlogout";
	# Print Screen → select area → copy screenshot to clipboard
	"Print" = "exec ${pkgs.writeShellScript "sway-screenshot" ''
	  ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - |
	    ${pkgs.wl-clipboard}/bin/wl-copy --type image/png
	''}";
	};

      input."type:keyboard" = {
        xkb_layout = "fi,ru";
        xkb_variant = "nodeadkeys,";
        xkb_options = "grp:alt_shift_toggle";
      };
    };
  };

  # Swaybar uses i3status. Declare precisely what appears on the bar.
  programs.i3status = {
    enable = true;
    enableDefault = false;
    general.interval = 10;

    modules = {
      "wireless _first_" = {
        position = 1;
        settings = {
          format_up = "WiFi: %essid %quality";
          format_down = "WiFi: disconnected";
          format_quality = "%d%s";
        };
      };

      "battery all" = {
        position = 2;
        settings = {
          format = "Battery: %percentage";
          format_percentage = "%.0f%s";
        };
      };

      "disk /" = {
        position = 3;
        settings.format = "Disk: %avail";
      };

      "tztime local" = {
        position = 4;
        settings.format = "%Y-%m-%d %H:%M";
      };
    };
  };
}
