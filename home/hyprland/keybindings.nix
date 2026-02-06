{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "Mod4"; # your wev said Mod4 for both Win + Command

    bind = [
      # --- launchers ---
      "$mod,Return,exec,kitty"
      "$mod,D,exec,wofi --show drun"
      "$mod,Escape,exec,wlogout" # optional; remove if you don't use wlogout

      # --- window actions ---
      "$mod,Q,killactive"
      "$mod,F,fullscreen"
      "$mod,Space,togglefloating"
      "$mod,P,pseudo"     # dwindle pseudo-tile
      "$mod,J,togglesplit" # dwindle split toggle

      # --- focus movement (vim keys) ---
      "$mod,H,movefocus,l"
      "$mod,L,movefocus,r"
      "$mod,K,movefocus,u"
      "$mod,J,movefocus,d"

      # --- move windows (vim keys) ---
      "$mod SHIFT,H,movewindow,l"
      "$mod SHIFT,L,movewindow,r"
      "$mod SHIFT,K,movewindow,u"
      "$mod SHIFT,J,movewindow,d"

      # --- workspaces (switch) ---
      "$mod,1,workspace,1"
      "$mod,2,workspace,2"
      "$mod,3,workspace,3"
      "$mod,4,workspace,4"
      "$mod,5,workspace,5"
      "$mod,6,workspace,6"
      "$mod,7,workspace,7"
      "$mod,8,workspace,8"
      "$mod,9,workspace,9"
      "$mod,0,workspace,10"

      # --- workspaces (move focused window) ---
      "$mod SHIFT,1,movetoworkspace,1"
      "$mod SHIFT,2,movetoworkspace,2"
      "$mod SHIFT,3,movetoworkspace,3"
      "$mod SHIFT,4,movetoworkspace,4"
      "$mod SHIFT,5,movetoworkspace,5"
      "$mod SHIFT,6,movetoworkspace,6"
      "$mod SHIFT,7,movetoworkspace,7"
      "$mod SHIFT,8,movetoworkspace,8"
      "$mod SHIFT,9,movetoworkspace,9"
      "$mod SHIFT,0,movetoworkspace,10"

      # --- workspace cycling ---
      "$mod,Tab,workspace,e+1"
      "$mod SHIFT,Tab,workspace,e-1"

      # --- screenshots (grim+slurp) ---
      ",Print,exec,grim -g \"$(slurp)\" - | wl-copy"
      "$mod,Print,exec,grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%F_%H-%M-%S).png"

      # --- reload hyprland config ---
      "$mod SHIFT,R,exec,hyprctl reload"
    ];

    bindm = [
      # mouse move/resize while holding mod (optional)
      "$mod,mouse:272,movewindow"
      "$mod,mouse:273,resizewindow"
    ];
  };
}
