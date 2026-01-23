{ config, secrets, ... }:
let
  createConfig = type: {
    base_url = "http://${
      config.containers."sonarr-${type}".localAddress
    }:${toString config.services.sonarr.settings.server.port}/${type}";
    api_key = secrets.sonarr.apiKey;

    media_naming = {
      series = "default";
      season = "default";
      episodes = {
        rename = true;
        standard = "default";
        daily = "default";
        anime = "default";
      };
    };

    # > recyclarr list qualities sonarr
    quality_definition.type = "${type}";
  };
in
{
  services.recyclarr = {
    enable = true;

    configuration.sonarr = {
      anime = createConfig "anime";
      series = createConfig "series";
    };
  };
}
