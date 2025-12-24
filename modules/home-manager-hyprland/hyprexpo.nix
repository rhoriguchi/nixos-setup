{
  colors,
  config,
  lib,
  pkgs,
  ...
}:
{
  # TODO HYPRLAND try https://www.reddit.com/r/hyprland/comments/1o30dsg/hyprexpoplus_outer_gaps_keyboard_navigation_and
  wayland.windowManager.hyprland = {
    plugins = [
      pkgs.hyprlandPlugins.hyprexpo
    ];

    settings = {
      bind = [
        "$mainMod, G, hyprexpo:expo, toggle"
      ];

      plugin.hyprexpo = {
        workspace_method = "first 1";

        bg_col = "rgb(${lib.removePrefix "#" colors.normal.accent})";
        gap_size = config.wayland.windowManager.hyprland.settings.general.gaps_out;
      };
    };
  };
}
