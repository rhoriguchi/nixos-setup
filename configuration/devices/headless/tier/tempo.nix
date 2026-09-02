{
  config,
  ...
}:
let
  grpcPort = 4317;
in
{
  fileSystems."/mnt/Data/Monitoring/tempo" = {
    depends = [ "/mnt/Data/Monitoring" ];
    device = "/var/lib/tempo";
    fsType = "none";
    options = [ "bind" ];
  };

  services = {
    tempo = {
      enable = true;

      settings = {
        server.http_listen_port = 3200;

        distributor.receivers.otlp.protocols.grpc.endpoint = "0.0.0.0:${toString grpcPort}";

        storage.trace = {
          backend = "local";
          wal.path = "/var/lib/tempo/wal";
          local.path = "/var/lib/tempo/blocks";
        };

        live_store = {
          wal.path = "/var/lib/tempo/live-store/traces";
          shutdown_marker_dir = "/var/lib/tempo/live-store/shutdown-marker";
        };

        backend_scheduler = {
          local_work_path = "/var/lib/tempo/backend-scheduler";
          provider.compaction.compaction.block_retention = "${toString (24 * 7)}h";
        };

        backend_worker.compaction.block_retention = "${toString (24 * 7)}h";
      };
    };
  };

  networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
    grpcPort
  ];
}
