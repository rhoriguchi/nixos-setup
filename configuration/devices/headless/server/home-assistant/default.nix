{ pkgs, config, ... }: {
  imports = [
    ./adguard.nix
    ./lovelace.nix
    ./mystrom.nix
    ./netatmo.nix
    ./nginx.nix
    ./person.nix
    ./postgres.nix
    ./unifi.nix
    ./weather.nix
    ./withings.nix
    ./yeelight.nix
  ];

  services.home-assistant = {
    enable = true;

    port = 8124;

    package = let
      homeAssistant = pkgs.home-assistant.overrideAttrs (_: {
        tests = [ ];
        doInstallCheck = false;
      });
      homeAssistantExtraPackages = homeAssistant.override { extraPackages = pythonPackages: [ pythonPackages.psycopg2 ]; };
    in homeAssistantExtraPackages.override {
      extraComponents = [
        "automation"
        "default_config"
        "frontend"
        "history"
        "homeassistant"
        "http"
        "light"
        "logger"
        "lovelace"
        "mobile_app"
        "mystrom"
        "netatmo"
        "person"
        "recorder"
        "sensor"
        "shell_command"
        "shelly"
        "sun"
        "switch"
        "system_health"
        "template"
        "unifi"
        "webhook"
        "yeelight"
      ];
    };

    autoExtraComponents = false;

    config = {
      homeassistant = {
        name = "Home";
        time_zone = config.time.timeZone;
        latitude = (import ../../../../secrets.nix).services.home-assistant.config.homeassistant.latitude;
        longitude = (import ../../../../secrets.nix).services.home-assistant.config.homeassistant.longitude;
        elevation = (import ../../../../secrets.nix).services.home-assistant.config.homeassistant.elevation;
        unit_system = "metric";
        temperature_unit = "C";
        currency = "CHF";
      };

      mobile_app = { };

      frontend = { };

      history.exclude.entities = [ "sensor.time" ];

      system_health = { };

      logger.default = "warning";
    };
  };
}
