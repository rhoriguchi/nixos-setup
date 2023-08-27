{ pkgs, config, secrets, ... }: {
  imports = [
    ./adguard.nix
    ./deluge.nix
    ./generate-wifi-guest-qr.nix
    ./lovelace.nix
    ./mystrom.nix
    ./netatmo.nix
    ./postgres.nix
    ./proxy.nix
    ./systemmonitor.nix
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
      extraPackages = ps: [ ps.psycopg2 ];

      extraComponents = [
        "default_config"

        "repairs"
        "update"

        # Manual added integrations
        "deluge"
        "mobile_app"
        "mystrom"
        "netatmo"
        "shelly"
        "unifi"
        "yeelight"
      ];
    };

    config = {
      homeassistant = {
        name = "Home";
        time_zone = config.time.timeZone;
        latitude = secrets.homeassistant.latitude;
        longitude = secrets.homeassistant.longitude;
        elevation = secrets.homeassistant.elevation;
        country = "CH";
        language = "en-GB";
        unit_system = "metric";
        temperature_unit = "C";
        currency = "CHF";
      };

      mobile_app = { };

      frontend = { };

      bluetooth = { };

      history = { };

      recorder.exclude.entities = [ "sensor.time" ];

      system_health = { };

      hardware = { };

      logger.default = "warning";
    };
  };
}
