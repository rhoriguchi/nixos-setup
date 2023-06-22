{ pkgs, colors, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = [ (pkgs.nerdfonts.override { fonts = [ "RobotoMono" ]; }) ];

  systemd.user.services.dunst.Install.WantedBy = [ "hyprland-session.target" ];

  services.dunst = {
    enable = true;

    # TODO adjust
    settings = {
      global = {
        origin = "top-center";
        offset = "60x12";
        separator_height = 2;
        padding = 12;
        horizontal_padding = 12;
        text_icon_padding = 12;
        frame_width = 4;
        separator_color = "frame";
        idle_threshold = 120;
        font = "RobotoMono Nerd Font";
        line_height = 0;
        format = ''
          <b>%s</b>
          %b'';
        alignment = "center";
        icon_position = "off";
        startup_notification = "false";
        corner_radius = 12;

        frame_color = colors.normal.accent;
        background = colors.bright.accent;
        foreground = colors.normal.black;
        timeout = 3;
      };
    };
  };

  # wayland.windowManager.hyprland.extraConfig = ''
  #   exec-once = ${pkgs.dunst}/bin/dunst
  # '';
}
