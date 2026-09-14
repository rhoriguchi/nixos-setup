{
  config,
  lib,
  pkgs,
  ...
}:
let
  containerCfg = config.containers.tvtracktime-application.config;

  rootBindmountDir = "/mnt/bindmount/tvtracktime";
  bindmountDir = "${rootBindmountDir}/seaweedfs";

  version = "1.1.34";
in
{
  sops = {
    secrets = {
      "services/tvTrackTime/dockerRegistryPassword".restartUnits = [
        config.systemd.services."container@tvtracktime-application".name
      ];

      "tvtracktime-postgres+services/tvTrackTime/postgres/password" = {
        key = "services/tvTrackTime/postgres/password";

        owner = "postgres";
        group = "postgres";

        restartUnits = [ config.systemd.services."container@tvtracktime-application".name ];
      };

      "tvtracktime-backend+services/tvTrackTime/postgres/password" = {
        key = "services/tvTrackTime/postgres/password";
      };

      "services/tvTrackTime/seaweedfs/accessKey" = { };
      "services/tvTrackTime/seaweedfs/secretKey" = { };

      "services/tvTrackTime/backend/jwtSecret" = { };
      "services/tvTrackTime/backend/turnstileSecret" = { };
      "services/tvTrackTime/backend/tvdbApiKey" = { };
      "services/tvTrackTime/backend/tmdbAccessToken" = { };
      "services/tvTrackTime/backend/githubToken" = { };
    };

    templates = {
      "services.tvtracktime.seaweedfs.s3ConfigFile" = {
        uid = 1000;
        gid = 1000;

        content = lib.toJSON {
          identities = [
            {
              name = "tvtracktime";
              credentials = [
                {
                  accessKey = config.sops.placeholder."services/tvTrackTime/seaweedfs/accessKey";
                  secretKey = config.sops.placeholder."services/tvTrackTime/seaweedfs/secretKey";
                }
              ];
              actions = [
                "Read"
                "Write"
                "List"
                "Tagging"
                "Admin"
              ];
            }

            {
              name = "anonymous";
              actions = [
                "Read"
              ];
            }
          ];
        };

        restartUnits = [ config.systemd.services."container@tvtracktime-application".name ];
      };

      "services.tvtracktime.backend.environmentFile" = {
        content = ''
          POSTGRES_PASSWORD=${
            config.sops.placeholder."tvtracktime-backend+services/tvTrackTime/postgres/password"
          }

          S3_ACCESS_KEY=${config.sops.placeholder."services/tvTrackTime/seaweedfs/accessKey"}
          S3_SECRET_KEY=${config.sops.placeholder."services/tvTrackTime/seaweedfs/secretKey"}

          JWT_SECRET=${config.sops.placeholder."services/tvTrackTime/backend/jwtSecret"}
          TURNSTILE_SECRET=${config.sops.placeholder."services/tvTrackTime/backend/turnstileSecret"}
          TVDB_API_KEY=${config.sops.placeholder."services/tvTrackTime/backend/tvdbApiKey"}
          TMDB_ACCESS_TOKEN=${config.sops.placeholder."services/tvTrackTime/backend/tmdbAccessToken"}
          GITHUB_TOKEN=${config.sops.placeholder."services/tvTrackTime/backend/githubToken"}
        '';

        restartUnits = [ config.systemd.services."container@tvtracktime-application".name ];
      };
    };
  };

  system.fsPackages = [ pkgs.bindfs ];
  fileSystems.${bindmountDir} = {
    depends = [ "/var/lib/tvtracktime-seaweedfs" ];
    device = "/var/lib/tvtracktime-seaweedfs";
    fsType = "fuse.bindfs";
    noCheck = true;
    options = [
      "map=root/1000:@root/@1000"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/tvtracktime-postgresql 0750 ${toString containerCfg.users.users.postgres.uid} ${toString containerCfg.users.groups.postgres.gid}"
    "d /var/lib/tvtracktime-seaweedfs 0750 root root"

    "d ${rootBindmountDir} 0750 root root"
    "d ${bindmountDir} 0750 root root"
  ];

  containers.tvtracktime-application = {
    autoStart = true;
    ephemeral = true;

    # Allow BPF system calls and capabilities required by crun/podman inside systemd-nspawn.
    # Without these, crun fails with "crun: bpf create: Operation not permitted: OCI permission denied".
    additionalCapabilities = [
      "CAP_BPF"
      "CAP_SYS_ADMIN"
    ];

    extraFlags = [
      "--system-call-filter=bpf"
    ];

    privateNetwork = true;
    hostAddress = "169.254.1.1";
    localAddress = "169.254.1.150";

    sopsPaths = [
      config.sops.secrets."services/tvTrackTime/dockerRegistryPassword".path
      config.sops.secrets."tvtracktime-postgres+services/tvTrackTime/postgres/password".path

      config.sops.templates."services.tvtracktime.backend.environmentFile".path
      config.sops.templates."services.tvtracktime.seaweedfs.s3ConfigFile".path
    ];

    bindMounts = {
      "${containerCfg.services.postgresql.dataDir}" = {
        isReadOnly = false;
        hostPath = "/var/lib/tvtracktime-postgresql";
      };

      "/var/lib/seaweedfs" = {
        isReadOnly = false;
        hostPath = bindmountDir;
      };
    };

    config = {
      systemd.services.postgresql.postStart = ''
        password="$(cat ${
          config.sops.secrets."tvtracktime-postgres+services/tvTrackTime/postgres/password".path
        })"
        ${containerCfg.services.postgresql.package}/bin/psql -tAc "ALTER ROLE tvtracktime WITH PASSWORD '$password';"
      '';

      services.postgresql = {
        enable = true;

        enableTCPIP = true;
        authentication = ''
          host all all ${config.containers.tvtracktime-application.hostAddress}/32 scram-sha-256
        '';

        ensureDatabases = [ "tvtracktime" ];
        ensureUsers = [
          {
            name = "tvtracktime";
            ensureDBOwnership = true;
          }
        ];
      };

      virtualisation.oci-containers.containers = {
        seaweedfs = {
          image = "docker.io/chrislusf/seaweedfs:4.40";

          networks = [ "host" ];

          cmd = [
            "server"

            # Override default volume server port (8080) to avoid collision with Spring Boot backend
            "-volume.port=8088"
            "-s3"
            "-s3.config=/etc/seaweedfs/s3.json"
          ];

          volumes = [
            "${
              config.sops.templates."services.tvtracktime.seaweedfs.s3ConfigFile".path
            }:/etc/seaweedfs/s3.json:ro"
            "/var/lib/seaweedfs:/data"
          ];
        };

        backend = {
          image = "ghcr.io/rhoriguchi/tvtracktime/backend:${version}";

          login = {
            registry = "ghcr.io";
            username = "rhoriguchi";
            passwordFile = config.sops.secrets."services/tvTrackTime/dockerRegistryPassword".path;
          };

          networks = [ "host" ];

          environmentFiles = [
            config.sops.templates."services.tvtracktime.backend.environmentFile".path
          ];

          environment = {
            SPRING_PROFILES_ACTIVE = "prod";

            POSTGRES_HOST = "127.0.0.1";
            POSTGRES_PORT = toString containerCfg.services.postgresql.settings.port;
            POSTGRES_DB = "tvtracktime";
            POSTGRES_USER = "tvtracktime";

            S3_URL = "http://127.0.0.1:8333";
            S3_BUCKET = "tvtracktime";

            TZ = config.time.timeZone;
          };
        };

        frontend = {
          image = "ghcr.io/rhoriguchi/tvtracktime/frontend:${version}";

          login = {
            registry = "ghcr.io";
            username = "rhoriguchi";
            passwordFile = config.sops.secrets."services/tvTrackTime/dockerRegistryPassword".path;
          };

          networks = [ "host" ];
        };
      };

      networking.firewall.allowedTCPPorts = [
        containerCfg.services.postgresql.settings.port

        80
        8080
        8333
      ];
    };
  };
}
