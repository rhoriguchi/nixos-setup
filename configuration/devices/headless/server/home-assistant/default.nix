{ pkgs, lib, config, secrets, ... }:
let
  getFiles = dir: lib.attrNames (builtins.readDir dir);
  filter = file:
    if lib.pathIsDirectory file then
      builtins.elem "default.nix" (getFiles file)
    else
      lib.hasSuffix ".nix" file && !(lib.hasSuffix "default.nix" file);
  getImports = dir: lib.filter filter (map (file: dir + "/${file}") (getFiles dir));
in {
  imports = getImports ./.;

  # TODO remove when https://github.com/project-chip/connectedhomeip/issues/25688 fixed
  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];

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
        "esphome"
        "homekit_controller"
        "hue"
        "mobile_app"
        "mystrom"
        "netatmo"
        "shelly"
        "unifi"
        "yeelight"
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

      history = { };

      recorder.exclude.entities = [ "sensor.time" ];

      system_health = { };

      hardware = { };

      logger.default = "warning";
    };
  };
}
