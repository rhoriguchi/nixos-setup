{ config, ... }:
let
  port = 3100;
in
{
  sops = {
    secrets."nginx+services/loki/pushPassword".key = "services/loki/pushPassword";

    templates."services.nginx.loki.htpasswd" = {
      content = "alloy:{PLAIN}${config.sops.placeholder."nginx+services/loki/pushPassword"}";

      owner = config.services.nginx.user;
      group = config.services.nginx.group;

      reloadUnits = [ config.systemd.services.nginx.name ];
    };
  };

  fileSystems."/mnt/Data/Monitoring/loki" = {
    depends = [ "/mnt/Data/Monitoring" ];
    device = config.services.loki.dataDir;
    fsType = "none";
    options = [ "bind" ];
  };

  services.loki = {
    enable = true;

    extraFlags = [ "-print-config-stderr" ];

    configuration = {
      auth_enabled = false;

      server = {
        http_listen_address = "127.0.0.1";
        http_listen_port = 56711;

        grpc_listen_port = 0;
      };

      ingester.lifecycler = {
        address = "127.0.0.1";

        ring = {
          kvstore.store = "inmemory";

          replication_factor = 1;
        };
      };

      # https://grafana.com/docs/loki/latest/operations/storage/schema
      schema_config = {
        configs = [
          {
            from = "2024-01-01";
            object_store = "filesystem";
            store = "tsdb";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };

      storage_config = {
        tsdb_shipper = {
          active_index_directory = "${config.services.loki.dataDir}/tsdb-index";
          cache_location = "${config.services.loki.dataDir}/tsdb-cache";
        };

        filesystem.directory = "${config.services.loki.dataDir}/chunks";
      };

      compactor = {
        working_directory = config.services.loki.dataDir;

        compactor_ring.kvstore.store = "inmemory";
      };

      tracing.enabled = false;
    };
  };

  services.nginx = {
    enable = true;

    virtualHosts."loki" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = port;
        }
      ];

      basicAuthFile = config.sops.templates."services.nginx.loki.htpasswd".path;

      extraConfig = ''
        access_log off;
        client_max_body_size 16m;
      '';

      locations = {
        "= /loki/api/v1/push".proxyPass =
          "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";

        "/".return = 404;
      };
    };
  };

  networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
    port
  ];
}
