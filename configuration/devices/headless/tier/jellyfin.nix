{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  rootBindmountDir = "/mnt/bindmount/jellyfin";
  bindmountDir1 = "${rootBindmountDir}/resilio-Movies";
  bindmountDir2 = "${rootBindmountDir}/resilio-Series";
  bindmountDir3 = "${rootBindmountDir}/disk-Movies";
  bindmountDir4 = "${rootBindmountDir}/disk-Series";
in
{
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems = {
    "${bindmountDir1}" = {
      depends = [ config.services.resilio.syncPath ];
      device = "${config.services.resilio.syncPath}/Movies";
      fsType = "fuse.bindfs";
      options = [
        # `ro` causes kernel panic
        "perms=0550"
        "map=${
          lib.concatStringsSep ":" [
            "${config.services.resilio.user}/${config.services.jellyfin.user}"
            "@${config.services.resilio.group}/@${config.services.jellyfin.group}"
          ]
        }"
      ];
    };

    "${bindmountDir2}" = {
      depends = [ config.services.resilio.syncPath ];
      device = "${config.services.resilio.syncPath}/Series";
      fsType = "fuse.bindfs";
      options = [
        # `ro` causes kernel panic
        "perms=0550"
        "map=${
          lib.concatStringsSep ":" [
            "${config.services.resilio.user}/${config.services.jellyfin.user}"
            "@${config.services.resilio.group}/@${config.services.jellyfin.group}"
          ]
        }"
      ];
    };

    "${bindmountDir3}" = {
      depends = [ "/mnt/Data/Movies" ];
      device = "/mnt/Data/Movies";
      fsType = "fuse.bindfs";
      options = [
        # `ro` causes kernel panic
        "perms=0550"
        "map=${
          lib.concatStringsSep ":" [
            "root/${config.services.jellyfin.user}"
            "@root/@${config.services.jellyfin.group}"
          ]
        }"
      ];
    };

    "${bindmountDir4}" = {
      depends = [ "/mnt/Data/Series" ];
      device = "/mnt/Data/Series";
      fsType = "fuse.bindfs";
      options = [
        # `ro` causes kernel panic
        "perms=0550"
        "map=${
          lib.concatStringsSep ":" [
            "root/${config.services.jellyfin.user}"
            "@root/@${config.services.jellyfin.group}"
          ]
        }"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${rootBindmountDir} 0550 ${config.services.jellyfin.user} ${config.services.jellyfin.group}"
    "d ${bindmountDir1} 0550 ${config.services.jellyfin.user} ${config.services.jellyfin.group}"
    "d ${bindmountDir2} 0550 ${config.services.jellyfin.user} ${config.services.jellyfin.group}"
    "d ${bindmountDir3} 0550 ${config.services.jellyfin.user} ${config.services.jellyfin.group}"
    "d ${bindmountDir4} 0550 ${config.services.jellyfin.user} ${config.services.jellyfin.group}"
  ];

  services = {
    declarative-jellyfin = {
      enable = true;

      logDir = "/var/log/jellyfin";

      users.admin = {
        mutable = false;
        password = secrets.jellyfin.users.admin.password;

        permissions = {
          isAdministrator = true;
          isHidden = true;
        };
      };

      network.enableRemoteAccess = false;

      system = {
        serverName = config.networking.hostName;

        pluginRepositories =
          lib.mapAttrsToList
            (key: value: {
              content = {
                Enabled = true;
                Name = key;
                Url = value;
              };
              tag = "RepositoryInfo";
            })
            {
              "Jellyfin Stable" = "https://repo.jellyfin.org/files/plugin/manifest.json";

              "Intro Skipper" = "https://intro-skipper.org/manifest.json";
              "Jellyfin SSO" =
                "https://raw.githubusercontent.com/9p4/jellyfin-plugin-sso/manifest-release/manifest.json";
            };
      };

      libraries =
        lib.mapAttrs
          (
            _: value:
            value
            // {
              automaticRefreshIntervalDays = 30;
              enableChapterImageExtraction = true;
              extractChapterImagesDuringLibraryScan = true;
            }
            // lib.optionalAttrs (value.contentType == "tvshows") {
              enableAutomaticSeriesGrouping = true;
            }
          )
          {
            "Movies" = {
              contentType = "movies";
              pathInfos = [
                "${bindmountDir1}/Movies"
                bindmountDir3
              ];
            };
            "Anime Movies" = {
              contentType = "movies";
              pathInfos = [
                "${bindmountDir1}/Anime"
              ];

              typeOptions.Movie = {
                metadataFetchers = [ "AniDB" ];
                imageFetchers = [
                  "AniDB"
                  "Embedded Image Extractor"
                  "Screen Grabber"
                ];
              };
            };

            "TV Shows" = {
              contentType = "tvshows";
              pathInfos = [
                "${bindmountDir2}/Tv Shows"
                "${bindmountDir4}/Tv Shows"
              ];
            };
            "Anime" = {
              contentType = "tvshows";
              pathInfos = [
                "${bindmountDir2}/Anime"
                "${bindmountDir4}/Anime"
              ];

              typeOptions = {
                Series = {
                  metadataFetchers = [ "AniDB" ];
                  imageFetchers = [ "AniDB" ];
                };
                Season = {
                  metadataFetchers = [ "AniDB" ];
                  imageFetchers = [ "AniDB" ];
                };
                Episode = {
                  metadataFetchers = [ "AniDB" ];
                  imageFetchers = [
                    "Embedded Image Extractor"
                    "Screen Grabber"
                  ];
                };
              };
            };
          };

      branding = {
        loginDisclaimer = ''
          <form action="https://jellyfin.example.com/sso/OID/start/authelia">
            <button class="raised block emby-button button-submit">
              Sign in with SSO
            </button>
          </form>
        '';

        customCss = ''
          a.raised.emby-button {
            padding: 0.9em 1em;
            color: inherit !important;
          }

          .disclaimerContainer {
            display: block;
          }
        '';
      };
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "jellyfin.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."jellyfin.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:8096";
            proxyWebsockets = true;

            extraConfig = ''
              proxy_buffering off;
            '';
          };

          "/metrics".return = 444;
        };
      };
    };
  };

  # systemd.services.jellyfin-configure = {
  #   enable = config.services.jellyfin.enable;

  #   after = [ config.systemd.services.jellyfin.name ];
  #   wants = [ config.systemd.services.jellyfin.name ];

  #   script = ''
  #     ${pkgs.xmlstarlet}/bin/xmlstarlet ed -L \
  #       -u "/BrandingOptions/LoginDisclaimer" \
  #         -v '${''
  #           <form action="https://jellyfin.example.com/sso/OID/start/PROVIDER_NAME">
  #             <button class="raised block emby-button button-submit">
  #               Sign in with SSO
  #             </button>
  #           </form>
  #         ''}' \
  #       -u "/BrandingOptions/CustomCss" \
  #         -v '${''
  #           a.raised.emby-button {
  #             padding: 0.9em 1em;
  #             color: inherit !important;
  #           }

  #           .disclaimerContainer {
  #             display: block;
  #           }
  #         ''}' \
  #       ${config.services.jellyfin.configDir}/branding.xml

  #     ${pkgs.xmlstarlet}/bin/xmlstarlet ed -L \
  #       -u '/NetworkConfiguration/EnableRemoteAccess' \
  #         -v 'false' \
  #       ${config.services.jellyfin.configDir}/network.xml

  #     ${pkgs.xmlstarlet}/bin/xmlstarlet ed -L \
  #       -u '/ServerConfiguration/ServerName' \
  #         -v '${config.networking.hostName}' \
  #       ${config.services.jellyfin.configDir}/system.xml

  #     ${pkgs.xmlstarlet}/bin/xmlstarlet ed -L \
  #         -s "/ServerConfiguration/PluginRepositories[not(RepositoryInfo/Name='Jellyfin SSO')]" \
  #           -t elem -n RepositoryInfo -v "" \
  #         -s "/ServerConfiguration/PluginRepositories/RepositoryInfo[not(Name)]" \
  #           -t elem -n Name -v "Jellyfin SSO" \
  #         -s "/ServerConfiguration/PluginRepositories/RepositoryInfo[Name='Jellyfin SSO' and not(Url)]" \
  #           -t elem -n Url -v "https://raw.githubusercontent.com/9p4/jellyfin-plugin-sso/manifest-release/manifest.json" \
  #         -s "/ServerConfiguration/PluginRepositories/RepositoryInfo[Name='Jellyfin SSO' and not(Enabled)]" \
  #           -t elem -n Enabled -v "true" \
  #       ${config.services.jellyfin.configDir}/system.xml
  #   '';

  #   serviceConfig = {
  #     User = config.services.jellyfin.user;
  #     Group = config.services.jellyfin.group;
  #     Type = "oneshot";
  #   };
  # };
}
