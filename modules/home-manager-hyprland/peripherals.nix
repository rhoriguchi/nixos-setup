{ config, pkgs, ... }:
let
  homeDirectory = config.home.homeDirectory;
in
{
  home.packages = [ pkgs.nwg-displays ];

  wayland.windowManager.hyprland.settings = {
    source = [
      "${homeDirectory}/.config/hypr/monitors.conf"
      "${homeDirectory}/.config/hypr/workspaces.conf"
    ];

    monitor = [ ", highres, auto, 1" ];

    input = {
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
  };
}
