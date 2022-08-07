{ pkgs, config, secrets, ... }: {
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

    package = (pkgs.home-assistant.overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    })).override {
      extraPackages = pythonPackages: [ pythonPackages.psycopg2 ];

      extraComponents = [
        "default_config"
        "repairs"

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
        latitude = secrets.services.home-assistant.config.homeassistant.latitude;
        longitude = secrets.services.home-assistant.config.homeassistant.longitude;
        elevation = secrets.services.home-assistant.config.homeassistant.elevation;
        unit_system = "metric";
        temperature_unit = "C";
        currency = "CHF";
      };

      mobile_app = { };

      frontend = { };

      bluetooth = { };

      history.exclude.entities = [ "sensor.time" ];

      system_health = { };

      logger.default = "warning";
    };
  };
}
