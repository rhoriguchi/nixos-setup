{ config, libCustom, ... }:
{
  imports = libCustom.getImports ./.;

  wayland.windowManager.hyprland = {
    enable = true;

    systemd.enable = false;

    settings.config = {
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

  # https://wiki.hypr.land/Configuring/Start/#autocompletions
  programs.vscode.profiles.default.userSettings."Lua.workspace.library" = [
    "${config.xdg.configHome}/hypr/.luarc.json"
  ];
}
