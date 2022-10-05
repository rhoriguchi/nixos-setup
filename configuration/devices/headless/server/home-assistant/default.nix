{ lib, pkgs, config, secrets, ... }:
let
  getFiles = dir: lib.attrNames (builtins.readDir dir);
  getImports = dir: map (file: dir + "/${file}") (lib.filter (file: file != "default.nix") (getFiles dir));
in {
  imports = getImports ./.;

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
        "update"

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
        latitude = secrets.homeassistant.latitude;
        longitude = secrets.homeassistant.longitude;
        elevation = secrets.homeassistant.elevation;
        unit_system = "metric";
        temperature_unit = "C";
        currency = "CHF";
      };

      mobile_app = { };

      frontend = { };

      bluetooth = { };

      history.exclude.entities = [ "sensor.time" ];

      system_health = { };

      hardware = { };

      logger.default = "warning";
    };
  };
}
