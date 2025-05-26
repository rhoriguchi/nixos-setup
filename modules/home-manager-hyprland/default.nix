{ lib, ... }: {
  imports = lib.custom.getImports ./.;

  # TODO HYPRLAND any of these good?
  # pkgs.hyprlandPlugins.borders-plus-plus      pkgs.hyprlandPlugins.hyprbars               pkgs.hyprlandPlugins.hyprscrolling          pkgs.hyprlandPlugins.mkHyprlandPlugin
  # pkgs.hyprlandPlugins.csgo-vulkan-fix        pkgs.hyprlandPlugins.hyprexpo               pkgs.hyprlandPlugins.hyprspace              pkgs.hyprlandPlugins.override
  # pkgs.hyprlandPlugins.hy3                    pkgs.hyprlandPlugins.hyprfocus              pkgs.hyprlandPlugins.hyprsplit              pkgs.hyprlandPlugins.overrideDerivation
  # pkgs.hyprlandPlugins.hycov                  pkgs.hyprlandPlugins.hyprgrass              pkgs.hyprlandPlugins.hyprtrails             pkgs.hyprlandPlugins.recurseForDerivations
  # pkgs.hyprlandPlugins.hypr-dynamic-cursors   pkgs.hyprlandPlugins.hyprscroller           pkgs.hyprlandPlugins.hyprwinwrap            pkgs.hyprlandPlugins.xtra-dispatchers

  wayland.windowManager.hyprland = {
    enable = true;

    systemd.enable = false;

    # Config keys https://github.com/hyprwm/Hyprland/blob/main/src/config/ConfigManager.cpp
    settings = {
      monitor = [ ", highres, auto, 1" ];

      input = {
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
          kb_variant = "en_US";
          kb_model = "pc104";
        }
        {
          name = "dygma-defy-keyboard";
          kb_layout = "us";
          kb_variant = "en_US";
          kb_model = "pc104";
        }
      ];

      gestures.workspace_swipe = true;

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;

        middle_click_paste = false;
      };

      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };
    };
  };
}
