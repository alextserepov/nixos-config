{ pkgs, ... }:

{
  wayland.windowManager.sway = {
    enable = true;

    config = {
      modifier = "Mod4";
      terminal = "${pkgs.cosmic-term}/bin/cosmic-term";

      input."type:keyboard" = {
        xkb_layout = "fi,ru";
        xkb_variant = "nodeadkeys,";
        xkb_options = "grp:alt_shift_toggle";
      };
    };
  };
}
