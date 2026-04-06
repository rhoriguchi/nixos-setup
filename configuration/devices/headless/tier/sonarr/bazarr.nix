{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  rootBindmountDir = "/mnt/bindmount/bazarr";
  bindmountDir1 = "${rootBindmountDir}/resilio";
  bindmountDir2 = "${rootBindmountDir}/disk";

  bazarrConfig = (pkgs.formats.yaml { }).generate "bazarr-config.yaml" {
    auth.apikey = secrets.bazarr.apiKey;

    general = {
      hostname = config.networking.hostName;

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
      ip = config.containers.sonarr-anime.localAddress;
      port = config.containers.sonarr-anime.config.services.sonarr.settings.server.port;
      sync_only_monitored_series = true;
      series_sync = 15;
    };

    analytics.enabled = false;
  };
in
{
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

  systemd = {
    tmpfiles.rules = [
      "d ${rootBindmountDir} 0550 ${config.services.bazarr.user} ${config.services.bazarr.group}"
      "d ${bindmountDir1} 0550 ${config.services.bazarr.user} ${config.services.bazarr.group}"
      "d ${bindmountDir2} 0550 ${config.services.bazarr.user} ${config.services.bazarr.group}"
    ];

    services.bazarr-setup = {
      enable = config.services.bazarr.enable;

      after = [ config.systemd.services.bazarr.name ];
      requires = [ config.systemd.services.bazarr.name ];

      script = ''
        configFile="${config.services.bazarr.dataDir}/config/config.yaml"
        dbFile="${config.services.bazarr.dataDir}/db/bazarr.db"

        if [ -f "$configFile" ] && [ -f "$dbFile" ]; then
          ${pkgs.yaml-merge}/bin/yaml-merge "$configFile" "${bazarrConfig}" > "$configFile.tmp"
          mv "$configFile.tmp" "$configFile"

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

          echo 'Restarting ${config.systemd.services.bazarr.name}'
          systemctl restart ${config.systemd.services.bazarr.name}
        fi
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };

  services = {
    bazarr.enable = true;

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

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.bazarr.listenPort}";

          recommendedProxySettings = false;

          extraConfig = ''
            include /run/nginx-authelia/auth.conf;
          '';
        };
      };
    };

    prometheus.exporters.exportarr-bazarr = {
      enable = config.services.bazarr.enable;

      port = 9710;

      url = "http://127.0.0.1:${toString config.services.bazarr.listenPort}";

      environment = {
        INTERFACE = "127.0.0.1";

        API_KEY = secrets.bazarr.apiKey;
      };
    };

    monitoring.extraPrometheusJobs = [
      {
        name = "Bazarr";
        url = "http://127.0.0.1:${toString config.services.prometheus.exporters.exportarr-bazarr.port}/metrics";
      }
    ];
  };
}
