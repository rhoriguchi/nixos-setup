{ config, lib, ... }:
let
  cfg = config.services.log-shipping;

  wireguardIps = import (lib.custom.relativeToRoot "modules/default/wireguard-network/ips.nix");
in {
  options.services.log-shipping = {
    enable = lib.mkEnableOption "Ship logs with Promtail to Loki";
    receiverHostname = lib.mkOption { type = lib.types.nullOr lib.types.str; };
    useLocalhost = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = config.services.wireguard-network.enable;
      message = "wireguard-network service must be enabled";
    }];

    services.promtail = {
      enable = true;

      configuration = {
        server = {
          http_listen_address = "127.0.0.1";
          http_listen_port = 9080;

          grpc_listen_port = 0;
        };

        positions.filename = "/tmp/positions.yaml";

        clients =
          [{ url = "http://${if cfg.useLocalhost then "127.0.0.1" else wireguardIps.${cfg.receiverHostname}}:3100/loki/api/v1/push"; }];

        scrape_configs = [{
          job_name = "systemd";

          journal = {
            max_age = "24h";

            labels.job = "systemd";

            path = "/var/log/journal";
          };

          relabel_configs = [
            {
              source_labels = [ "__journal__hostname" ];
              target_label = "host";
            }
            {
              source_labels = [ "__journal_priority_keyword" ];
              target_label = "severity";
            }
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
              regex = "(.+\\.service)";
            }
            {
              source_labels = [ "__journal__systemd_user_unit" ];
              target_label = "user_unit";
              regex = "(.+\\.service)";
            }
          ];
        }];
      };
    };
  };
}
