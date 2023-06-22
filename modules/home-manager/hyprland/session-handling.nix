{ pkgs, lib, config, colors, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = [ (pkgs.nerdfonts.override { fonts = [ "RobotoMono" ]; }) ];

  services.swayidle = {
    enable = true;

    systemdTarget = "hyprland-session.target";

    timeouts = [
      {
        timeout = 5 * 60;
        command = "${config.programs.swaylock.package}/bin/swaylock";
      }
      {
        timeout = 10 * 60;
        command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
      {
        timeout = 15 * 60;
        # TODO replace with suspend-then-hibernate
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];

    events = [
      {
        event = "before-sleep";
        command = "${config.programs.swaylock.package}/bin/swaylock --daemonize --show-failed-attempts";
      }
      {
        event = "after-resume";
        command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
    ];
  };

  programs.swaylock = {
    enable = true;

    package = pkgs.swaylock-effects;

    settings = let
      removeHashtag = str: lib.removePrefix "#" str;

      insideColor = "00000088";
      textColor = removeHashtag colors.normal.white;
    in {
      daemonize = true;
      ignore-empty-password = true;
      show-failed-attempts = true;

      image = "${./wallpaper.jpg}";

      clock = true;
      timestr = "%H:%M:%S";
      datestr = "%d.%m.%Y";

      indicator = true;
      indicator-radius = 100;
      indicator-thickness = 7;

      font = "RobotoMono Nerd Font";
      line-color = "00000000";
      separator-color = "00000000";

      inside-color = insideColor;
      text-color = textColor;
      ring-color = removeHashtag colors.normal.accent;

      key-hl-color = removeHashtag colors.bright.accent;
      bs-hl-color = removeHashtag colors.normal.yellow;

      inside-caps-lock-color = insideColor;
      text-caps-lock-color = textColor;
      ring-caps-lock-color = removeHashtag colors.normal.white;

      inside-wrong-color = insideColor;
      text-wrong-color = textColor;
      ring-wrong-color = removeHashtag colors.normal.red;

      inside-clear-color = insideColor;
      text-clear-color = textColor;
      ring-clear-color = removeHashtag colors.normal.yellow;

      inside-ver-color = insideColor;
      text-ver-color = textColor;
      ring-ver-color = removeHashtag colors.normal.blue;
    };
  };

  wayland.windowManager.hyprland.extraConfig = ''
    bind = $mainMod, L, exec, ${config.programs.swaylock.package}/bin/swaylock
  '';
}
