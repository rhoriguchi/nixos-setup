{
  # TODO HYPRLAND make it more red
  services.hyprsunset = {
    enable = true;

    transitions = {
      sunrise = {
        calendar = "*-*-* 06:00:00";
        requests = [ [ "identity" ] ];
      };

      sunset = {
        calendar = "*-*-* 20:00:00";
        requests = [[ "temperature" "3700" ]];
      };
    };
  };
}
