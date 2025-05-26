{
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "hyprlock";

        before_sleep_cmd = "hyprlock";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 5 * 60;
          on-timeout = "hyprlock";
        }
        {
          timeout = 10 * 60;
          on-timeout = "hyprctl dispatch dpms off";

          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
