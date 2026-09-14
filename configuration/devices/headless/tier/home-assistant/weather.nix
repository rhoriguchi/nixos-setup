{
  config,
  pkgs,
  ...
}:
let
  units = config.services.home-assistant.config.homeassistant.unit_system;

  apiUrl = "https://api.openweathermap.org/data/2.5";

  script = pkgs.writers.writeBash "openweather.sh" ''
    apiKey="$(cat ${config.sops.secrets."services/home-assistant/openWeatherMap/apiKey".path})"
    lat="$(cat ${config.sops.secrets."services/home-assistant/location/latitude".path})"
    lon="$(cat ${config.sops.secrets."services/home-assistant/location/longitude".path})"
    output="$(${pkgs.curl}/bin/curl --silent "${apiUrl}/weather?appid=$apiKey&lat=$lat&lon=$lon&units=${units}" | ${pkgs.jq}/bin/jq '.main.temp')"
    echo "''${output:-0}"
  '';
in
{
  sops.secrets = {
    "services/home-assistant/openWeatherMap/apiKey" = {
      owner = "hass";
      group = "hass";

      restartUnits = [ config.systemd.services.home-assistant.name ];
    };

    "services/home-assistant/location/latitude" = {
      owner = "hass";
      group = "hass";

      restartUnits = [ config.systemd.services.home-assistant.name ];
    };

    "services/home-assistant/location/longitude" = {
      owner = "hass";
      group = "hass";

      restartUnits = [ config.systemd.services.home-assistant.name ];
    };
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
