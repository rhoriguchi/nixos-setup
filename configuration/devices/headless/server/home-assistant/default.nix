{ config, lib, pkgs, secrets, ... }: {
  imports = lib.custom.getImports ./.;

  services.home-assistant = {
    enable = true;

    package = (pkgs.home-assistant.overrideAttrs (oldAttrs: {
      doCheck = false;
      doInstallCheck = false;

      patches = (oldAttrs.patches or [ ]) ++ [ ./patches/govee-light-local-scane-interval.patch ];
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
        "shelly"
      ];
    };

    config = {
      homeassistant = {
        name = "Home";
        time_zone = config.time.timeZone;
        latitude = secrets.home.latitude;
        longitude = secrets.home.longitude;
        elevation = secrets.home.elevation;
        country = "CH";
        language = "en-GB";
        unit_system = "metric";
        temperature_unit = "C";
        currency = "CHF";

        auth_providers = [
          { type = "homeassistant"; }
          {
            type = "trusted_networks";
            allow_bypass_login = true;
            trusted_networks = [ "192.168.100.0/24" ];
            trusted_users."192.168.100.0/24" = [ "41ca5ba9634b43f2b1d6f3b8d038c4cb" ];
          }
        ];
      };

      mobile_app = { };

      frontend = { };

      sun = { };

      history = { };

      recorder.exclude.entities = [ "sensor.time" ];

      system_health = { };

      hardware = { };

      logger.default = "warning";
    };
  };
}
