{ config, lib, pkgs, secrets, ... }: {
  imports = lib.custom.getImports ./.;

  networking.firewall.allowedUDPPorts = [
    4002 # Govee lights local
  ];

  services.home-assistant = {
    enable = true;

    package = (pkgs.home-assistant.overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    })).override {
      extraPackages = ps: [
        # Discord
        ps.setuptools

        # Postgres
        ps.psycopg2
      ];

      extraComponents = [
        "default_config"

        "repairs"
        "update"

        # Manual added integrations
        "deluge"
        "discord"
        "esphome"
        "govee_light_local"
        "homekit_controller"
        "hue"
        "mobile_app"
        "netatmo"
        "shelly"
      ];
    };

    customComponents = [ pkgs.home-assistant-custom-components.localtuya ];

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

      sun = { };

      history = { };

      recorder.exclude.entities = [ "sensor.time" ];

      system_health = { };

      hardware = { };

      logger.default = "warning";
    };
  };
}
