{ lib, ... }: {
  imports = lib.custom.getImports ./.;

  # TODO HYPRLAND use plugins?
  # hyprland-plugins = {
  #   url = "github:hyprwm/hyprland-plugins";
  #   inputs.hyprland.follows = "hyprland";
  # };

  wayland.windowManager.hyprland = {
    enable = true;

    systemd.enable = false;

    # Config keys https://github.com/hyprwm/Hyprland/blob/main/src/config/ConfigManager.cpp
    settings = {
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;

        disable_autoreload = false;

        middle_click_paste = false;
      };

      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };
    };
  };

  services.hyprpolkitagent.enable = true;
}
