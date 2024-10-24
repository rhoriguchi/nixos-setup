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

  networking.firewall.allowedUDPPorts = [
    4002 # Govee lights local
  ];

  # TODO remove when https://github.com/project-chip/connectedhomeip/issues/25688 fixed
  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];

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
        "yeelight"
      ];
    };

    customComponents = [
      pkgs.home-assistant-custom-components.localtuya

      ((pkgs.python3Packages.callPackage (import "${
          pkgs.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "90f4ec0eab20235cd0fd2c5d81fbe0533c893d6f";
            hash = "sha256-sqtWDeetBasTX8qRPTwTXRCK+T5u9KqK9CukNtB+4sc=";
          }
        }/pkgs/servers/home-assistant/custom-components/dirigera_platform/package.nix") { }).overrideAttrs
        (_: { dontCheckManifest = true; }))
    ];

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
