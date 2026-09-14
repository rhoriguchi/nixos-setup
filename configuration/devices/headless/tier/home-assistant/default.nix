{
  config,
  lib,
  libCustom,
  pkgs,
  ...
}:
{
  imports = libCustom.getImports ./.;

  sops = {
    secrets = {
      "services/home-assistant/location/latitude" = { };
      "services/home-assistant/location/longitude" = { };
      "services/home-assistant/location/elevation" = { };
    };

    templates."services.home-assistant.secretsFile" = {
      owner = "hass";
      group = "hass";

      content = ''
        latitude: ${config.sops.placeholder."services/home-assistant/location/latitude"}
        longitude: ${config.sops.placeholder."services/home-assistant/location/longitude"}
        elevation: ${config.sops.placeholder."services/home-assistant/location/elevation"}
      '';

      restartUnits = [ config.systemd.services.home-assistant.name ];
    };
  };

  services.home-assistant = {
    enable = true;

    package =
      (pkgs.home-assistant.overrideAttrs (oldAttrs: {
        doCheck = false;
        doInstallCheck = false;

        patches = (oldAttrs.patches or [ ]) ++ [ ./patches/govee-light-local-scane-interval.patch ];
      })).override
        {
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
            "airgradient"
            "deluge"
            "discord"
            "govee_light_local"
            "homekit_controller"
            "hue"
            "mobile_app"
            "shelly"
            "thread"
          ];
        };

    config = {
      homeassistant = {
        name = "Home";
        time_zone = config.time.timeZone;
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = "!secret elevation";
        country = "CH";
        language = "en-GB";
        unit_system = "metric";
        temperature_unit = "C";
        currency = "CHF";
      };

      http.server_port = 8123;

      mobile_app = { };

      frontend = { };

      sun = { };

      history = { };

      recorder = {
        exclude.entities = [ "sensor.time" ];

        auto_purge = true;
        purge_keep_days = 30;
      };

      system_health = { };

      hardware = { };

      logger.default = "warning";
    };
  };

  systemd.services.home-assistant.preStart = lib.mkAfter ''
    ln -sf ${
      config.sops.templates."services.home-assistant.secretsFile".path
    } "${config.services.home-assistant.configDir}/secrets.yaml"
  '';
}
