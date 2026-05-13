{
  config,
  lib,
  secrets,
  ...
}:
let
  createConfig =
    type:
    {
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
        }
        // lib.optionalAttrs (type == "anime") {
          anime = "default";
        };
      };

      # > recyclarr list qualities sonarr
      quality_definition.type = type;

      delete_old_custom_formats = true;
    }
    // lib.optionalAttrs (type == "anime") {
      # https://github.com/recyclarr/config-templates/blob/master/sonarr/templates/anime-sonarr-v4.yml
      include = [
        {
          template = "sonarr-quality-definition-anime";
        }
        {
          template = "sonarr-v4-custom-formats-anime";
        }
        {
          template = "sonarr-v4-quality-profile-anime";
        }
      ];
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
