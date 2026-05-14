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
      # > recyclarr list custom-format-groups sonarr
      custom_format_groups = {
        add = [
          # [Release Groups] Anime
          {
            trash_id = "f206572b1147d0221bb1c96765b349e8";
            select_all = true;
          }
          # [Streaming Services] Anime
          {
            trash_id = "f54985e5e96747cef58731f1cf4c9181";
            select_all = true;
          }
        ];

        skip = [
          "6f0872eebfc95b1f93474b7ac866ced0" # [Unwanted] Unwanted Formats German
          "a23c8675c79118544fd74153394fa589" # [Unwanted] Unwanted Formats French
        ];
      };

      # > recyclarr list quality-profiles sonarr
      quality_profiles = [
        { trash_id = "20e0fc959f1f1704bed501f23bdae76f"; } # [Anime] Remux-1080p
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
