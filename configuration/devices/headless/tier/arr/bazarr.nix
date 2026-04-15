{
  config,
  lib,
  libCustom,
  pkgs,
  secrets,
  ...
}:
let
  bazarrUid = 361;
  bazarrGid = 361;

  rootBindmountDir = "/mnt/bindmount/bazarr";
  bindmountDir1 = "${rootBindmountDir}/resilio";
  bindmountDir2 = "${rootBindmountDir}/disk";

  getContainerCfg = type: config.containers."bazarr-${type}".config;

  createContainer =
    type:
    let
      containerCfg = getContainerCfg type;
    in
    {
      autoStart = true;
      ephemeral = true;

      privateNetwork = true;
      hostAddress = "169.254.1.1";
      localAddress =
        {
          anime = "169.254.1.178";
          series = "169.254.1.193";
        }
        .${type};

      bindMounts = {
        "${containerCfg.services.bazarr.dataDir}" = {
          isReadOnly = false;
          hostPath = "/var/lib/bazarr-${type}";
        };

        "${bindmountDir1}" = {
          isReadOnly = false;
          hostPath = bindmountDir1;
        };

        "${bindmountDir2}" = {
          isReadOnly = false;
          hostPath = bindmountDir2;
        };
      };

      config = {
        # TODO remove when merged https://nixpkgs-tracker.ocfox.me/?pr=507378
        imports = [ (libCustom.relativeToRoot "modules/default/bazarr-overlay.nix") ];

        nixpkgs.pkgs = pkgs;
        system.stateVersion = config.system.stateVersion;

        users = {
          users.${config.services.bazarr.user} = {
            group = config.services.bazarr.group;
            uid = bazarrUid;
          };

          groups.${config.services.bazarr.group}.gid = bazarrGid;
        };

        systemd.services.bazarr-setup = {
          enable = true;

          wants = [ containerCfg.systemd.services.bazarr.name ];
          after = [ containerCfg.systemd.services.bazarr.name ];
          wantedBy = [ "multi-user.target" ];

          script = ''
            dbFile="${containerCfg.services.bazarr.dataDir}/db/bazarr.db"
            if [ -f "$dbFile" ]; then
              ${pkgs.sqlite-interactive}/bin/sqlite3 "$dbFile" << 'EOF'
                DELETE FROM table_languages_profiles;

                INSERT OR REPLACE INTO table_languages_profiles (
                  profileId,
                  name,
                  items,
                  mustNotContain,
                  mustContain,
                  originalFormat
                )
                VALUES (
                  1,
                  'Default',
                  '[{"id": 1, "language": "en", "audio_exclude": "False", "audio_only_include": "False", "hi": "False", "forced": "False"}]',
                  '[]',
                  '[]',
                  0
                );
            EOF

              echo 'Restarting bazarr.service'
              systemctl restart bazarr.service
            fi
          '';

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
        };

        services = {
          bazarr = {
            enable = true;

            openFirewall = true;

            mutableSettings = false;
            settings = {
              auth.apikey = secrets.bazarr.apiKey;

              general = {
                instance_name = "Bazarr ${lib.toSentenceCase type}";
                base_url = "/${type}";

                path_mappings = [
                  [
                    "/mnt/bindmount/sonarr/resilio-Series"
                    bindmountDir1
                  ]
                  [
                    "/mnt/bindmount/sonarr/disk-Series"
                    bindmountDir2
                  ]
                ];

                serie_default_enabled = true;
                serie_default_profile = 1;

                enabled_providers = [
                  "animetosho"
                  "opensubtitlescom"
                  "supersubtitles"
                  "tvsubtitles"
                  "yifysubtitles"
                ];
                enabled_integrations = [ "anidb" ];

                use_sonarr = true;
              };

              opensubtitlescom = {
                username = secrets.opensSubtitles.username;
                password = secrets.opensSubtitles.password;
              };

              anidb = {
                api_client = secrets.bazarr.anidb.apiClient;
                api_client_ver = 1;
              };

              sonarr = {
                apikey = secrets.sonarr.apiKey;
                ip = config.containers."sonarr-${type}".localAddress;
                port = config.containers."sonarr-${type}".config.services.sonarr.settings.server.port;
                base_url = "/${type}";
                sync_only_monitored_series = true;
                series_sync = 15;
              };
            };
          };

          prometheus.exporters.exportarr-bazarr = {
            enable = true;

            openFirewall = true;

            url = "http://127.0.0.1:${toString containerCfg.services.bazarr.listenPort}/${type}";

            environment.API_KEY = containerCfg.services.bazarr.settings.auth.apikey;
          };
        };
      };
    };

  createNginxVirtualHostLocation =
    type:
    let
      containerCfg = getContainerCfg type;
    in
    {
      proxyPass = "http://${
        config.containers."bazarr-${type}".localAddress
      }:${toString containerCfg.services.bazarr.listenPort}";

      extraConfig = ''
        include /run/nginx-authelia/auth.conf;
      '';
    };
in
{
  assertions = [
    {
      assertion = !(lib.elem bazarrUid (lib.attrValues config.ids.uids));
      message = "Bazarr UID ${toString bazarrUid} is already in use in config.ids.uids";
    }
    {
      assertion = !(lib.elem bazarrGid (lib.attrValues config.ids.gids));
      message = "Bazarr GID ${toString bazarrGid} is already in use in config.ids.gids";
    }
  ];

  users = {
    users.${config.services.bazarr.user} = {
      group = config.services.bazarr.group;
      uid = bazarrUid;
    };

    groups.${config.services.bazarr.group}.gid = bazarrGid;
  };

  system.fsPackages = [ pkgs.bindfs ];
  fileSystems = {
    "${bindmountDir1}" = {
      depends = [ config.services.resilio.syncPath ];
      device = "${config.services.resilio.syncPath}/Series";
      fsType = "fuse.bindfs";
      noCheck = true;
      options = [
        "map=${
          lib.concatStringsSep ":" [
            "${config.services.resilio.user}/${config.services.bazarr.user}"
            "@${config.services.resilio.group}/@${config.services.bazarr.group}"
          ]
        }"
      ];
    };

    "${bindmountDir2}" = {
      depends = [ "/mnt/Data/Series" ];
      device = "/mnt/Data/Series";
      fsType = "fuse.bindfs";
      noCheck = true;
      options = [
        "map=${
          lib.concatStringsSep ":" [
            "root/${config.services.bazarr.user}"
            "@root/@${config.services.bazarr.group}"
          ]
        }"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/bazarr-anime 0750 ${config.services.bazarr.user} ${config.services.bazarr.group}"
    "d /var/lib/bazarr-series 0750 ${config.services.bazarr.user} ${config.services.bazarr.group}"

    "d ${rootBindmountDir} 0550 ${config.services.bazarr.user} ${config.services.bazarr.group}"
    "d ${bindmountDir1} 0550 ${config.services.bazarr.user} ${config.services.bazarr.group}"
    "d ${bindmountDir2} 0550 ${config.services.bazarr.user} ${config.services.bazarr.group}"
  ];

  containers = {
    bazarr-anime = createContainer "anime";
    bazarr-series = createContainer "series";
  };

  services = {
    monitoring.extraPrometheusJobs =
      map
        (
          type:
          let
            containerCfg = getContainerCfg type;
          in
          {
            name = "Bazarr ${lib.toSentenceCase type}";
            url = "http://${
              config.containers."bazarr-${type}".localAddress
            }:${toString containerCfg.services.prometheus.exporters.exportarr-bazarr.port}/metrics";
          }
        )
        [
          "anime"
          "series"
        ];

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "bazarr.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."bazarr.00a.ch" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;

        extraConfig = ''
          include /run/nginx-authelia/location.conf;
        '';

        locations = {
          "/".return = "302 /anime";

          "/anime" = createNginxVirtualHostLocation "anime";
          "/series" = createNginxVirtualHostLocation "series";
        };
      };
    };
  };
}
