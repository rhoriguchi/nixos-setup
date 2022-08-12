{ pkgs, config, secrets, ... }:
let
  apiKey = secrets.openWeatherMap.apiKey;
  lat = config.services.home-assistant.config.homeassistant.latitude;
  lon = config.services.home-assistant.config.homeassistant.longitude;
  units = config.services.home-assistant.config.homeassistant.unit_system;

  apiUrl = "https://api.openweathermap.org/data/2.5";
in {
  services.home-assistant.config.sensor = [{
    platform = "command_line";
    name = "OpenWeather current temperature";
    scan_interval = 5 * 60;
    command = ''${pkgs.curl}/bin/curl "${apiUrl}/weather?appid=${apiKey}&lat=${toString lat}&lon=${toString lon}&units=${units}"'';
    value_template = "{{ value_json.main.temp }}";
    unit_of_measurement = "°C";
  }];
}
