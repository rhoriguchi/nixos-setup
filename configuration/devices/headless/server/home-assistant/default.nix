{ pkgs, config, ... }: {
  imports = [
    ./adguard.nix
    ./generate-wifi-guest-qr.nix
    ./lovelace.nix
    ./mystrom.nix
    ./netatmo.nix
    ./nginx.nix
    ./postgres.nix
    ./unifi.nix
    ./weather.nix
    ./yeelight.nix
  ];

  services.home-assistant = {
    enable = true;

    package = let
      homeAssistant = pkgs.home-assistant.overrideAttrs (_: {
        tests = [ ];
        doInstallCheck = false;
      });
      homeAssistantExtraPackages = homeAssistant.override { extraPackages = pythonPackages: [ pythonPackages.psycopg2 ]; };
    in homeAssistantExtraPackages.override {
      extraComponents = [
        "default_config"

        # Manual added integrations
        "mobile_app"
        "netatmo"
        "shelly"
        "unifi"
        "yeelight"
      ];
    };

    config = {
      http.server_port = 8124;

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
