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
      kb_layout = "fi";
      kb_variant = "nodeadkeys";

      repeat_delay = 500;
      repeat_rate = 18;

      touchpad = {
        natural_scroll = true;
        scroll_factor = 0.35;
        disable_while_typing = true;
        tap-to-click = true;
      };
    };
  };
}
