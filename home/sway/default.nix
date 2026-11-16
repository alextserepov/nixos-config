{ pkgs, lib, ... }:

{
  xdg.configFile."networkmanager-dmenu/config.ini".text = ''
    [dmenu]
    dmenu_command = ${pkgs.wofi}/bin/wofi --dmenu --insensitive
    list_saved = True
    highlight = True
    prompt = Networks

    [dmenu_passphrase]
    obscure = True
  '';

  home.packages = with pkgs; [
    cosmic-term
    wofi
    networkmanager_dmenu
    hyprlock
    wlogout
  ];

  wayland.windowManager.sway = {
    enable = true;

    config = {
      modifier = "Mod4";
      terminal = "cosmic-term";
      menu = "wofi --show drun";

      startup = [
        {
	  command = "${pkgs.autotiling-rs}/bin/autotiling-rs";
	  always = false;
        }
	{
          command = "bindpeek";
	  always = false;
	}
      ];

      keybindings = lib.mkOptionDefault {
      	"Mod4+q" = "kill";
	"Mod4+w" = "exec hyprlock";
	"Mod4+space" = "layout toggle all";
	"Mod4+Escape" = "exec wlogout";
	"Mod4+e" = "exec thunar";
	"Mod4+n" = "exec networkmanager_dmenu";

	# Print Screen → select area → copy screenshot to clipboard
	"Print" = "exec ${pkgs.writeShellScript "sway-screenshot" ''
	  ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - |
	    ${pkgs.wl-clipboard}/bin/wl-copy --type image/png
	''}";
	# Volume with on-screen feedback
	"XF86AudioRaiseVolume" =
	  "exec swayosd-client --output-volume raise --max-volume 100";

	"XF86AudioLowerVolume" =
	  "exec swayosd-client --output-volume lower";

	"XF86AudioMute" =
	  "exec swayosd-client --output-volume mute-toggle";

	"XF86AudioMicMute" =
	  "exec swayosd-client --input-volume mute-toggle";

	# Open full graphical audio controls
	"Mod4+Shift+v" =
	  "exec pavucontrol";
	};

      input."type:keyboard" = {
        xkb_layout = "fi,ru";
        xkb_variant = "nodeadkeys,";
        xkb_options = "grp:alt_shift_toggle";
      };
    };
  };

  services.swayosd.enable = true;

  # Swaybar uses i3status. Declare precisely what appears on the bar.
  programs.i3status = {
    enable = true;
    enableDefault = false;
    general = {
      interval = 10;
      colors = true;
      color_good = "#c4c4c4";
      color_degraded = "#e5c07b";
      color_bad = "#e06c75";
    };

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
	  threshold_type = "percentage";
	  low_treshold = 20;
        };
      };

      "disk /" = {
        position = 3;
        settings.format = "Disk: %avail";
	threshold_type = "gbytes_avail";
	low_threshold = 100;
      };

      "tztime local" = {
        position = 4;
        settings.format = "%Y-%m-%d %H:%M";
      };
    };
  };
}
