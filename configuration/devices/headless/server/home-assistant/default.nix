{ pkgs, config, ... }: {
  imports = [
    ./group.nix
    ./lametric.nix
    ./lovelace.nix
    ./mystrom.nix
    ./netatmo.nix
    ./person.nix
    ./postgres.nix
    ./telegram.nix
    ./unifi.nix
    ./yeelight.nix
  ];

  services = {
    # TODO HOME-ASSISTANT commented
    # nginx = {
    #   enable = true;

    #   virtualHosts."0.0.0.0" = {
    #     forceSSL = true;
    #     enableACME = true;

    #     extraConfig = ''
    #       proxy_buffering off;
    #     '';

    #     locations."/" = {
    #       proxyPass = "http://127.0.0.1:8123";
    #       proxyWebsockets = true;
    #     };
    #   };
    # };

    # TODO HOME-ASSISTANT manual steps
    # - Create default user
    # - Delete all areas
    # - Add integrations
    #   - Netatmo
    #   - Ubiquiti UniFi

    home-assistant = {
      enable = true;

      # (self: super: {
      #   python = super.python.override {
      #     packageOverrides = python-self: python-super: {
      #       python-telegram-bot = python-super.python-telegram-bot.overrideAttrs (oldAttrs: {
      #         src = super.fetchPypi {
      #           pname = "python-telegram-bot";
      #           version = "13.1";
      #           sha256 = "10l23j46b5sh26qqs0dmjhwxh8bakwmkf1acxcfbgmq8xl4bpvjz";
      #         };
      #       });
      #     };
      #   };
      # })

      package = let
        homeAssistant = pkgs.home-assistant.overrideAttrs (_: {
          tests = [ ];
          doInstallCheck = false;
        });
        homeAssistantExtraPackages = homeAssistant.override { extraPackages = pythonPackages: [ pythonPackages.psycopg2 ]; };
      in homeAssistantExtraPackages.override {
        extraComponents = [
          "default_config"
          "frontend"
          "group"
          "history"
          "homeassistant"
          "http"
          "lametric"
          "logger"
          "mystrom"
          "netatmo"
          "notify"
          "person"
          "recorder"
          "sun"
          "switch"
          "system_health"
          "telegram_bot"
          "template"
          "unifi"
          "yeelight"
        ];
      };

      autoExtraComponents = false;
      openFirewall = true;

      # TODO HOME-ASSISTANT remove
      configWritable = true;

      config = {
        homeassistant = {
          name = "Home";
          time_zone = config.time.timeZone;
          latitude = (import ../../../../secrets.nix).services.home-assistant.config.homeassistant.latitude;
          longitude = (import ../../../../secrets.nix).services.home-assistant.config.homeassistant.longitude;
          elevation = (import ../../../../secrets.nix).services.home-assistant.config.homeassistant.elevation;
          unit_system = "metric";
          temperature_unit = "C";
        };

        frontend = { };

        history.exclude = {
          entities = [ "sensor.time" ];
        };

        sun = { };

        system_health = { };

        # TODO HOME-ASSISTANT uncomment
        # logger.default = "error";
      };
    };
  };
}
