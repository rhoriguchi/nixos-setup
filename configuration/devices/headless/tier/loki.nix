{ config, ... }:
{
  fileSystems."/mnt/Data/Monitoring/loki" = {
    depends = [ "/mnt/Data/Monitoring" ];
    device = config.services.loki.dataDir;
    fsType = "none";
    options = [ "bind" ];
  };

  services = {
    loki = {
      enable = true;

      extraFlags = [ "-print-config-stderr" ];

      configuration = {
        auth_enabled = false;

        server = {
          http_listen_address = "0.0.0.0";
          http_listen_port = 3100;

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

        analytics.reporting_enabled = false;
        tracing.enabled = false;
      };
    };

    logShipping.useLocalhost = true;
  };

  networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
    config.services.loki.configuration.server.http_listen_port
  ];
}
