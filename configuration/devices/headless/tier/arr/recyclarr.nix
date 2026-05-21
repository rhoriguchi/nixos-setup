{
  config,
  lib,
  secrets,
  ...
}:
let
  createCustomFormatGroup =
    customFormatGroup:
    map (trashId: {
      trash_id = trashId;
      select_all = true;
    }) customFormatGroup;

  sonarrCommonCustomFormatGroups = [
    "59c3af66780d08332fdc64e68297098f" # [Unwanted] Unwanted Formats
    "6f0872eebfc95b1f93474b7ac866ced0" # [Unwanted] Unwanted Formats German
    "a23c8675c79118544fd74153394fa589" # [Unwanted] Unwanted Formats French
  ];

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
      custom_format_groups.add = createCustomFormatGroup (
        [
          "f206572b1147d0221bb1c96765b349e8" # [Release Groups] Anime
          "f54985e5e96747cef58731f1cf4c9181" # [Streaming Services] Anime
        ]
        ++ sonarrCommonCustomFormatGroups
      );

      # > recyclarr list quality-profiles sonarr
      quality_profiles = [
        { trash_id = "20e0fc959f1f1704bed501f23bdae76f"; } # [Anime] Remux-1080p
      ];
    }
    // lib.optionalAttrs (type == "series") {
      # > recyclarr list custom-format-groups sonarr
      custom_format_groups.add = createCustomFormatGroup (
        [
          "b4a4353e3b3e6789dbef07677ff23686" # [Release Groups] HQ
          "abe720fab2d27682adc2a735136cec02" # [Streaming Services] General
        ]
        ++ sonarrCommonCustomFormatGroups
      );
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
