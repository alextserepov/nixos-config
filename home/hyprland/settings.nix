{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    
    exec-once = [
      "waybar"
      "mako"
    ];

    general = {
      gaps_in = 5;
      gaps_out = 10;
      border_size = 2;
      layout = "dwindle";
    };

    decoration = {
      rounding = 8;
      blur.enabled = true;
    };

    input = {
      kb_layout = "fi,ru";
      kb_variant = "nodeadkeys";
      kb_options = "grp:alt_shift_toggle";
      touchpad = {
        natural_scroll = true;
	scroll_factor = 0.35;
	disable_while_typing = true;
	tap-to-click = true;
      };
    };
  };
}
