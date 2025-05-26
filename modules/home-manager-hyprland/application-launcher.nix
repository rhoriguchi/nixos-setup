{ colors, config, lib, pkgs, ... }: {
  home.packages = [ pkgs.nerd-fonts.roboto-mono ];

  programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        terminal = "${pkgs.foot}/bin/foot -e";

        layer = "overlay";

        font = "RobotoMono Nerd Font";
        icon-theme = config.gtk.iconTheme.name;

        # TODO HYPRLAND figure out alignment
        prompt = ''"❯   "'';
        inner-pad = 5;
      };

      border.width = 2;

      colors = {
        background = lib.removePrefix "#" "${colors.extra.terminal.background}E6";
        border = lib.removePrefix "#" "${colors.normal.accent}FF";

        text = lib.removePrefix "#" "${colors.normal.white}FF";
        match = lib.removePrefix "#" "${colors.bright.accent}FF";

        selection-text = lib.removePrefix "#" "${colors.normal.white}FF";
        selection-match = lib.removePrefix "#" "${colors.normal.accent}FF";
        selection = lib.removePrefix "#" "${colors.bright.accent}FF";
      };
    };
  };

  wayland.windowManager.hyprland.settings.bind = [ "$mainMod, R, exec, ${config.programs.fuzzel.package}/bin/fuzzel" ];
}
