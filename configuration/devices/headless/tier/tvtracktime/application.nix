{
  config,
  pkgs,
  secrets,
  ...
}:
let
  containerCfg = config.containers.tvtracktime-application.config;

  rootBindmountDir = "/mnt/bindmount/tvtracktime";
  bindmountDir = "${rootBindmountDir}/seaweedfs";

  s3ConfigFile = pkgs.writers.writeJSON "s3.json" {
    identities = [
      {
        name = "tvtracktime";
        credentials = [
          {
            accessKey = secrets.tvtracktime.seaweedfs.accessKey;
            secretKey = secrets.tvtracktime.seaweedfs.secretKey;
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
in
{
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems."${bindmountDir}" = {
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
      nixpkgs.pkgs = pkgs;
      system.stateVersion = config.system.stateVersion;

      systemd.services.postgresql.postStart = ''
        ${containerCfg.services.postgresql.package}/bin/psql -tAc "ALTER ROLE tvtracktime WITH PASSWORD '${secrets.tvtracktime.postgres.password}';"
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
            "-dir=/var/lib/seaweedfs"
            # Override default volume server port (8080) to avoid collision with Spring Boot backend
            "-volume.port=8088"
            "-s3"
            "-s3.config=/etc/seaweedfs/s3.json"
          ];

          volumes = [
            "${s3ConfigFile}:/etc/seaweedfs/s3.json:ro"
            "/var/lib/seaweedfs:/var/lib/seaweedfs"
          ];
        };

        backend = {
          image = "ghcr.io/rhoriguchi/tvtracktime/backend:1.1.14";

          login = {
            registry = "ghcr.io";
            username = "rhoriguchi";
            passwordFile = "${pkgs.writeText "password" secrets.tvtracktime.dockerRegistryPassword}";
          };

          networks = [ "host" ];

          environment = {
            SPRING_PROFILES_ACTIVE = "prod";

            POSTGRES_HOST = "127.0.0.1";
            POSTGRES_PORT = toString containerCfg.services.postgresql.settings.port;
            POSTGRES_DB = "tvtracktime";
            POSTGRES_USER = "tvtracktime";
            POSTGRES_PASSWORD = secrets.tvtracktime.postgres.password;

            S3_URL = "http://127.0.0.1:8333";
            S3_BUCKET = "tvtracktime";
            S3_ACCESS_KEY = secrets.tvtracktime.seaweedfs.accessKey;
            S3_SECRET_KEY = secrets.tvtracktime.seaweedfs.secretKey;

            TURNSTILE_SECRET = secrets.tvtracktime.turnstileSecret;
            JWT_SECRET = secrets.tvtracktime.jwtSecret;
            TVDB_API_KEY = secrets.tvtracktime.tvdbApiKey;

            TZ = config.time.timeZone;
          };
        };

        frontend = {
          image = "ghcr.io/rhoriguchi/tvtracktime/frontend:1.1.14";

          login = {
            registry = "ghcr.io";
            username = "rhoriguchi";
            passwordFile = "${pkgs.writeText "password" secrets.tvtracktime.dockerRegistryPassword}";
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
