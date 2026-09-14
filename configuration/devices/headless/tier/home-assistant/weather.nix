{
  config,
  pkgs,
  ...
}:
let
  lat = config.services.home-assistant.config.homeassistant.latitude;
  lon = config.services.home-assistant.config.homeassistant.longitude;
  units = config.services.home-assistant.config.homeassistant.unit_system;

  apiUrl = "https://api.openweathermap.org/data/2.5";

  script = pkgs.writers.writeBash "openweather.sh" ''
    apiKey="$(cat ${config.sops.secrets."services/home-assistant/openWeatherMap/apiKey".path})"
    output="$(${pkgs.curl}/bin/curl --silent "${apiUrl}/weather?appid=$apiKey&lat=${toString lat}&lon=${toString lon}&units=${units}" | ${pkgs.jq}/bin/jq '.main.temp')"
    echo "''${output:-0}"
  '';
in
{
  sops.secrets."services/home-assistant/openWeatherMap/apiKey" = {
    owner = config.systemd.services.home-assistant.serviceConfig.User;
    group = config.systemd.services.home-assistant.serviceConfig.Group;

    restartUnits = [ config.systemd.services.home-assistant.name ];
  };

  services.home-assistant.config.command_line = [
    {
      sensor = {
        name = "OpenWeather current temperature";
        scan_interval = 5 * 60;
        command = script;
        value_template = "{{ value | float }}";
        unit_of_measurement = "°C";
        state_class = "measurement";
      };
    }
  ];
}
