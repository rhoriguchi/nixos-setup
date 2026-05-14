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

  radarrCommonCustomFormatGroups = [
    "a3ac6af01d78e4f21fcb75f601ac96df" # [Unwanted] Unwanted Formats
    "0ca61b4b233178d07113082a7acff72d" # [Unwanted] Unwanted Formats German
    "59f7ab9ff64d0026b011b985b1cc8670" # [Unwanted] Unwanted Formats French
  ];

  createSonarrConfig =
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

  createRadarrConfig =
    type:
    {
      base_url = "http://${
        config.containers."radarr-${type}".localAddress
      }:${toString config.services.radarr.settings.server.port}/${type}";
      api_key = secrets.radarr.apiKey;

      media_naming = {
        folder = "default";
        movie = {
          rename = true;
          standard = "standard";
        };
      };

      # > recyclarr list qualities radarr
      quality_definition = {
        type = if type == "movies" then "movie" else type;
      };

      delete_old_custom_formats = true;
    }
    // lib.optionalAttrs (type == "anime") {
      # > recyclarr list custom-format-groups radarr
      custom_format_groups.add = createCustomFormatGroup (
        [
          "1f8404f7f72c7edc8901f2f3589d1a91" # [Release Groups] Anime
          "f993ad37540147e4d00e66503545d81b" # [Streaming Services] Anime
        ]
        ++ radarrCommonCustomFormatGroups
      );

      # > recyclarr list quality-profiles radarr
      quality_profiles = [
        { trash_id = "722b624f9af1e492284c4bc842153a38"; } # [Anime] Remux-1080p
      ];
    }
    // lib.optionalAttrs (type == "movies") {
      # > recyclarr list custom-format-groups radarr
      custom_format_groups.add = createCustomFormatGroup (
        [
          "b2f2af430f73f3ad1f9948f33e0f0cf8" # [Release Groups] HQ
          "d9cc9a504e5ede6294c8b973aad4f028" # [Streaming Services] General
        ]
        ++ radarrCommonCustomFormatGroups
      );

      # > recyclarr list quality-profiles radarr
      quality_profiles = [
        { trash_id = "d1d67249d3890e49bc12e275d989a7e9"; } # [Movies] HD Bluray + WEB

        {
          name = "Any";
          qualities =
            map
              (name: {
                inherit name;
                enabled = true;
              })
              [
                "Remux-1080p"
                "Bluray-1080p"
                "WEB 1080p"
                "HDTV-1080p"
                "Bluray-720p"
                "WEB 720p"
                "HDTV-720p"
                "Bluray-576p"
                "Bluray-480p"
                "WEB 480p"
                "DVD-R"
                "DVD"
                "SDTV"
                "DVDSCR"
                "REGIONAL"
                "TELECINE"
                "TELESYNC"
                "CAM"
                "WORKPRINT"
              ];
        }
      ];
    };
in
{
  services.recyclarr = {
    enable = true;

    configuration = {
      sonarr = {
        sonarr-anime = createSonarrConfig "anime";
        sonarr-series = createSonarrConfig "series";
      };

      radarr = {
        radarr-anime = createRadarrConfig "anime";
        radarr-movies = createRadarrConfig "movies";
      };
    };
  };
}
