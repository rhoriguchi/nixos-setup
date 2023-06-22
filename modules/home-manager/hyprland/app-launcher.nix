{ pkgs, lib, colors, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "RobotoMono" ]; })

    pkgs.papirus-icon-theme
  ];

  programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        terminal = "${pkgs.foot}/bin/foot -e";

        layer = "overlay";

        font = "RobotoMono Nerd Font";
        icon-theme = "Papirus";

        prompt = "❯  ";
        inner-pad = 5;
      };

      border.width = 2;

      colors = let toRGBANoTransparency = color: "${lib.removePrefix "#" color}FF";
      in {
        background = "303030E6";
        border = toRGBANoTransparency colors.normal.accent;

        text = toRGBANoTransparency colors.normal.white;
        match = toRGBANoTransparency colors.bright.accent;

        selection-text = toRGBANoTransparency colors.normal.white;
        selection-match = toRGBANoTransparency colors.normal.accent;
        selection = toRGBANoTransparency colors.bright.accent;
      };
    };
  };

  wayland.windowManager.hyprland.extraConfig = ''
    bind = $mainMod, R, exec, ${pkgs.fuzzel}/bin/fuzzel
  '';
}
