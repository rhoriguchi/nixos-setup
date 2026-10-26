{
  config,
  lib,
  pkgs,
  ...
}:
let
  specs = {
    radarr = {
      types = {
        anime = "169.254.1.145";
        movies = "169.254.1.20";
      };

      defaultType = "movies";
      categoryField = "movieCategory";

      notificationEvents = [
        "onGrab"
        "onDownload"
        "onUpgrade"
        "onRename"
        "onMovieAdded"
        "onMovieDelete"
        "onMovieFileDelete"
        "onMovieFileDeleteForUpgrade"
        "onApplicationUpdate"
        "onManualInteractionRequired"
      ];

      bindmounts = [
        {
          dir = "disk-Movies";
          device = "/mnt/Data/Movies";
        }
      ];
    };

    sonarr = {
      types = {
        anime = "169.254.1.136";
        series = "169.254.1.202";
      };

      defaultType = "anime";
      categoryField = "tvCategory";

      notificationEvents = [
        "onGrab"
        "onDownload"
        "onUpgrade"
        "onImportComplete"
        "onRename"
        "onSeriesAdd"
        "onSeriesDelete"
        "onEpisodeFileDelete"
        "onEpisodeFileDeleteForUpgrade"
        "onApplicationUpdate"
        "onManualInteractionRequired"
      ];

      bindmounts = [
        {
          dir = "sync-Series";
          device = "${config.services.syncthing.dataDir}/Series";
          depends = [ config.services.syncthing.dataDir ];
          user = config.services.syncthing.user;
          group = config.services.syncthing.group;
          options = [
            # tmpfiles `d` on the mount point would otherwise chmod the syncthing
            # folder root through bindfs, making it read-only for syncthing
            "chmod-ignore"
          ];
        }
        {
          dir = "disk-Series";
          device = "/mnt/Data/Series";
        }
      ];
    };
  };

  mkArr =
    name:
    {
      types,
      defaultType,
      categoryField,
      notificationEvents,
      bindmounts,
    }:
    let
      Name = lib.toSentenceCase name;

      rootBindmountDir = "/mnt/bindmount/${name}";
      mountPath = m: "${rootBindmountDir}/${m.dir}";

      instance = type: "${name}-${type}";
      typeNames = lib.attrNames types;
      forTypes =
        createInstance:
        lib.mapAttrs' (type: _: lib.nameValuePair (instance type) (createInstance type)) types;

      getContainerCfg = type: config.containers.${instance type}.config;

      baseUrl =
        type:
        "http://${types.${type}}:${toString (getContainerCfg type).services.${name}.settings.server.port}";

      uidCfg = getContainerCfg defaultType;
      userUid = toString uidCfg.users.users.${uidCfg.services.${name}.user}.uid;
      groupGid = toString uidCfg.users.groups.${uidCfg.services.${name}.group}.gid;

      containerUnits = map (type: config.systemd.services."container@${instance type}".name) typeNames;

      createContainer =
        type:
        let
          containerCfg = getContainerCfg type;

          localAddress = types.${type};
        in
        {
          autoStart = true;
          ephemeral = true;

          privateNetwork = true;
          hostAddress = "169.254.1.1";
          inherit localAddress;

          bindMounts = {
            "${containerCfg.services.${name}.dataDir}" = {
              isReadOnly = false;
              hostPath = "/var/lib/${instance type}";
            };

            "/mnt/Data/Deluge" = {
              isReadOnly = false;
              hostPath = "/mnt/Data/Deluge";
            };
          }
          // lib.pipe bindmounts [
            (map (
              m:
              lib.nameValuePair (mountPath m) {
                isReadOnly = false;
                hostPath = mountPath m;
              }
            ))

            lib.listToAttrs
          ];

          sopsPaths = [
            config.sops.secrets."${name}+services/${name}/apiKey".path
            config.sops.templates."services.${name}.environmentFile".path
          ];

          config = {
            users = {
              users = {
                "${config.services.${name}.user}".extraGroups = [ config.services.deluge.group ];

                "${config.services.deluge.user}" = {
                  group = config.services.deluge.group;
                  uid = config.ids.uids.deluge;
                  home = config.services.deluge.dataDir;
                };
              };

              groups.${config.services.deluge.group}.gid = config.ids.gids.deluge;
            };

            services = {
              ${name} = {
                enable = true;

                openFirewall = true;

                # https://wiki.servarr.com/${name}/environment-variables
                settings = {
                  app.instancename = "${Name} ${lib.toSentenceCase type}";

                  server = {
                    urlbase = "/${type}";

                    allowedhosts = lib.concatStringsSep "," [
                      "${name}.00a.ch"

                      "127.0.0.1"
                      localAddress
                    ];
                  };

                  auth = {
                    method = "Forms";
                    required = "DisabledForLocalAddresses";
                  };
                };

                environmentFiles = [ config.sops.templates."services.${name}.environmentFile".path ];
              };

              prometheus.exporters."exportarr-${name}" = {
                apiKeyFile = config.sops.secrets."${name}+services/${name}/apiKey".path;
              };
            };

            systemd.services.${name}.serviceConfig.PrivateUsers = lib.mkForce false;
          };
        };

      createNginxVirtualHostLocation = type: {
        proxyPass = baseUrl type;

        proxyWebsockets = true;
        recommendedProxySettings = false;

        extraConfig = ''
          include /run/nginx-authelia/auth.conf;

          proxy_buffering off;

          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Server $host;
        '';
      };

      jellyfinWebhookUrlTemplate = type: "services.declarr.${instance type}.jellyfinWebhookUrl";

      createJellyfinWebhookUrlTemplate = type: {
        owner = config.services.declarr.user;

        content = "http://${
          config.containers."${name}-${type}".hostAddress
        }:${toString config.services.declarative-jellyfin.network.internalHttpPort}/library/refresh?ApiKey=${
          config.sops.placeholder."declarr+services/jellyfin/apiKeys/${name}"
        }";

        restartUnits = [ config.systemd.services.declarr.name ];
      };

      createDeclarrConfig =
        type:
        let
          delugeContainer = config.containers.deluge;
        in
        {
          declarr = {
            type = name;
            url = "${baseUrl type}/${type}";

            # Webhook url embeds the api key, so it comes from a sops template
            resolvePaths = [ "$.notification.*.fields.url" ];
          };

          config = {
            host.apiKey = config.sops.secrets."declarr+services/${name}/apiKey".path;

            ui = {
              calendarWeekColumnHeader = "ddd DD/MM";
              shortDateFormat = "DD MMM YYYY";
              longDateFormat = "dddd, D MMMM YYYY";
              timeFormat = "HH:mm";
            };
          };

          downloadClient.Deluge = {
            implementation = "Deluge";

            fields = {
              host = delugeContainer.localAddress;
              port = delugeContainer.config.services.deluge.web.port;
              # remove-web-login.patch makes the Deluge web UI always log in with the default password
              password = "deluge";
              ${categoryField} = instance type;
            };
          };

          notification."Jellyfin Webhook" = {
            implementation = "Webhook";

            fields = {
              url = config.sops.templates.${jellyfinWebhookUrlTemplate type}.path;
              method = 1;
            };
          }
          // lib.genAttrs notificationEvents (_: true);
        };
    in
    {
      sops = {
        secrets = {
          "${name}+services/${name}/apiKey" = {
            key = "services/${name}/apiKey";

            restartUnits = containerUnits;
          };

          "declarr+services/${name}/apiKey" = {
            key = "services/${name}/apiKey";

            owner = config.services.declarr.user;
            restartUnits = [ config.systemd.services.declarr.name ];
          };

          "declarr+services/jellyfin/apiKeys/${name}".key = "services/jellyfin/apiKeys/${name}";
        };

        templates = {
          "services.${name}.environmentFile" = {
            content = ''
              ${lib.toUpper name}__AUTH__APIKEY=${config.sops.placeholder."${name}+services/${name}/apiKey"}
            '';

            restartUnits = containerUnits;
          };
        }
        // lib.mapAttrs' (
          type: _: lib.nameValuePair (jellyfinWebhookUrlTemplate type) (createJellyfinWebhookUrlTemplate type)
        ) types;
      };

      fileSystems = lib.pipe bindmounts [
        (map (
          bindmount:
          lib.nameValuePair (mountPath bindmount) {
            depends = bindmount.depends or [ bindmount.device ];
            inherit (bindmount) device;
            fsType = "fuse.bindfs";
            noCheck = true;
            options = (bindmount.options or [ ]) ++ [
              "map=${
                lib.concatStringsSep ":" [
                  "${bindmount.user or "root"}/${userUid}"
                  "@${bindmount.group or "root"}/@${groupGid}"
                ]
              }"
            ];
          }
        ))

        lib.listToAttrs
      ];

      systemd.tmpfiles.rules =
        map (type: "d /var/lib/${instance type} 0750 ${userUid} ${groupGid}") typeNames
        ++ lib.pipe bindmounts [
          (map mountPath)
          (lib.concat [ rootBindmountDir ])
          (map (dir: "d ${dir} 0550 ${userUid} ${groupGid}"))
        ];

      containers = forTypes createContainer;

      services = {
        declarr.config = forTypes createDeclarrConfig;

        infomaniak = {
          enable = true;

          hostnames = [
            "${name}.00a.ch"
          ];
        };

        nginx = {
          enable = true;

          virtualHosts."${name}.00a.ch" = {
            enableACME = true;
            forceSSL = true;

            extraConfig = ''
              include /run/nginx-authelia/location.conf;
            '';

            locations = {
              "/".return = "302 /${defaultType}";
            }
            // lib.mapAttrs' (
              type: _: lib.nameValuePair "/${type}" (createNginxVirtualHostLocation type)
            ) types;
          };
        };
      };

      systemd.services.declarr =
        let
          requiredUnits = containerUnits ++ [
            config.systemd.services."container@deluge".name
            config.systemd.services.jellyfin.name
          ];
        in
        {
          wants = requiredUnits;
          after = requiredUnits;
        };
    };
in
{
  config = lib.mkMerge (
    [ { system.fsPackages = [ pkgs.bindfs ]; } ] ++ lib.mapAttrsToList mkArr specs
  );
}
