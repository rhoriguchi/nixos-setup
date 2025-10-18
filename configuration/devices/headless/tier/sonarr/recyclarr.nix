{ config, secrets, ... }:
{
  services.recyclarr = {
    enable = true;

    configuration.sonarr.main = {
      base_url = "http://localhost:${toString config.services.sonarr.settings.server.port}";
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

      # TODO commented since there are 2 options `Series` and `Anime`, deploy Sonaar twice to use this
      # > recyclarr list qualities sonarr
      # quality_definition.type = "XXX";
    };
  };
}
