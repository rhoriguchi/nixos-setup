{
  imports = [
    ./app-launcher.nix
    ./background.nix
    ./binds.nix
    ./notification
    ./screenshot.nix
    ./session-handling.nix
    ./theme.nix
    ./waybar.nix
    ./window-rules.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    extraConfig = ''
      # TODO probably can be removed once gtk pointer is configured
      # Some default env vars.
      env = XCURSOR_SIZE,24

      # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
      input {
        kb_layout = ch
        kb_variant = de_nodeadkeys
        kb_model = pc105
        kb_options =
        kb_rules =

        follow_mouse = 1

        touchpad {
            natural_scroll = no
        }

        sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
      }

      misc {
        disable_splash_rendering = true
      }

      dwindle {
        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = yes # you probably want this
      }

      master {
        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        new_is_master = true
      }

      gestures {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        workspace_swipe = off
      }

      # Example per-device config
      # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
      device:epic-mouse-v1 {
        sensitivity = -0.5
      }
    '';
  };
}
