{ pkgs, libCustom, ... }:
{
  home.packages = [ pkgs.nwg-displays ];

  wayland.windowManager.hyprland = {
    settings = {
      monitor = [
        {
          output = "";
          mode = "highres";
          scale = 1;
        }
      ];

      config.input = {
        repeat_delay = 500;
        repeat_rate = 30;

        kb_layout = "ch";
        kb_variant = "de_nodeadkeys";
        kb_model = "pc105";

        resolve_binds_by_sym = true;

        touchpad = {
          clickfinger_behavior = true;
          natural_scroll = true;
        };
      };

      device = [
        {
          name = "keychron-k8-keychron-k8";
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
        }
        {
          name = "dygma-defy-keyboard";
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
        }
      ];

      bind = [
        (libCustom.hyprland.mkBindRule {
          mods = "SUPER";
          key = "mouse:272";
          dispatcher = "dragWindow";
          flags.mouse = true;
        })
        (libCustom.hyprland.mkBindRule {
          mods = "SUPER";
          key = "mouse:273";
          dispatcher = "resizeWindow";
          flags.mouse = true;
        })
      ];

      gesture = [
        {
          fingers = 3;
          direction = "horizontal";
          action = "workspace";
        }
      ];
    };

    extraConfig = ''
      require("monitors")
      require("workspaces")
    '';
  };
}
