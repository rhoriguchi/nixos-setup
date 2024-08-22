{ config, pkgs, lib, ... }:
let
  cfg = config.services.monitoring;

  streamPort = 19996;

  isParent = cfg.type == "parent";
  isChild = cfg.type == "child";

  wireguardIps = import ./wireguard-network/ips.nix;

  frrEnabled = builtins.any (service: config.services.frr.${service}.enable) [ "bfd" "bgp" "ospf" "pim" ];
in {
  options.services.monitoring = {
    enable = lib.mkEnableOption "Monitoring with Netdata";
    type = lib.mkOption { type = lib.types.nullOr (lib.types.enum [ "parent" "child" ]); };
    parentHostname = lib.mkOption { type = lib.types.nullOr lib.types.str; };
    apiKey = lib.mkOption { type = lib.types.str; };
    webPort = lib.mkOption {
      type = lib.types.port;
      default = 19999;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.wireguard-network.enable;
        message = "wireguard-network service must be enabled";
      }
      {
        assertion = isParent -> builtins.elem config.networking.hostName (lib.attrNames wireguardIps);
        message = "When type is parent hostname must be wireguard host";
      }
      {
        assertion = isChild -> cfg.parentHostname != null;
        message = "When type is child parentHostname must be set";
      }
      {
        assertion = isChild -> builtins.elem cfg.parentHostname (lib.attrNames wireguardIps);
        message = "When type is child parentHostname must be wireguard host";
      }
    ];

    services = {
      nginx.statusPage = true;

      # TODO workaround for https://github.com/NixOS/nixpkgs/issues/204189
      postgresql.initialScript = if config.services.postgresql.enable then
        pkgs.writeText "initialScript" ''
          CREATE USER netdata;
          GRANT pg_monitor TO netdata;
        ''
      else
        null;

      frr_exporter = {
        enable = frrEnabled;

        collectors = {
          bfd = config.services.frr.bfd.enable;
          bgp = config.services.frr.bgp.enable;
          ospf = config.services.frr.ospf.enable;
          pim = config.services.frr.pim.enable;
        };
      };

      netdata = {
        enable = true;

        package = pkgs.netdata.override {
          withCloudUi = isParent;
          withCups = config.services.printing.enable;
        };

        # TODO monitor
        # Dnsmasq DHCP https://www.netdata.cloud/integrations/data-collection/dns-and-dhcp-servers/dnsmasq-dhcp
        # HDD temperature https://www.netdata.cloud/integrations/data-collection/hardware-devices-and-sensors/hdd-temperature
        # Minecraft https://www.netdata.cloud/integrations/data-collection/gaming/minecraft
        # nftables https://www.netdata.cloud/integrations/data-collection/linux-systems/firewall/nftables
        # Nvidia GPU https://www.netdata.cloud/integrations/data-collection/hardware-devices-and-sensors/nvidia-gpu
        # NVMe devices https://www.netdata.cloud/integrations/data-collection/storage-mount-points-and-filesystems/nvme-devices
        # S.M.A.R.T. https://www.netdata.cloud/integrations/data-collection/hardware-devices-and-sensors/s.m.a.r.t.

        # TODO install on windows (Plugin: go.d.plugin Module: windows)

        config = {
          parent = {
            db = {
              mode = "dbengine";
              "storage tiers" = 3;

              # Tier 0, per second data
              "dbengine tier 0 disk space MB" = 0;
              "dbengine tier 0 retention days" = 14;

              # Tier 1, per minute data
              "dbengine tier 1 disk space MB" = 0;
              "dbengine tier 1 retention days" = 30 * 3;

              # Tier 2, per hour data
              "dbengine tier 2 disk space MB" = 0;
              "dbengine tier 2 retention days" = 30 * 12;
            };

            web = {
              "bind to" = lib.concatStringsSep " " [
                "127.0.0.1:${toString cfg.webPort}=dashboard|registry|badges|management|netdata.conf"
                "${wireguardIps.${config.networking.hostName}}:${toString streamPort}=streaming"
              ];

              "enable gzip compression" = "no";
            };
          };

          child = {
            db.mode = "ram";

            web.mode = "none";

            ml.enabled = "no";
          };
        }.${cfg.type};

        configDir = {
          "stream.conf" = (pkgs.formats.ini { }).generate "stream.conf" {
            parent.${cfg.apiKey}.enabled = "yes";

            child.stream = {
              enabled = "yes";

              "api key" = cfg.apiKey;
              destination = "${wireguardIps.${cfg.parentHostname}}:${toString streamPort}";
            };
          }.${cfg.type};
        } // lib.optionalAttrs config.services.dnsmasq.enable {
          "go.d/dnsmasq.conf" = pkgs.writers.writeYAML "dnsmasq.conf" {
            jobs = [{
              name = "local";
              address = "127.0.0.1:${toString config.services.dnsmasq.settings.port}";
            }];
          };
        } // lib.optionalAttrs config.services.nginx.enable {
          "go.d/nginx.conf" = pkgs.writers.writeYAML "nginx.conf" {
            jobs = [{
              name = "nginx_local";
              url = "http://127.0.0.1/nginx_status";
            }];
          };
        } // {
          "go.d/ping.conf" = pkgs.writers.writeYAML "ping.conf" {
            jobs = [{
              name = "internet";
              update_every = 10;
              hosts = [ "1.1.1.1" "digitec.ch" "youtube.com" ];
            }] ++ lib.optional (config.services.wireguard-network.type == "client") {
              name = "wireguard";
              update_every = 10;
              hosts = [ (import ./wireguard-network/ips.nix).${config.services.wireguard-network.serverHostname} ];
            };
          };
        } // lib.optionalAttrs frrEnabled {
          "go.d/prometheus.conf" = pkgs.writers.writeYAML "prometheus.conf" {
            jobs = [{
              name = "frr_exporter_local";
              url = "http://127.0.0.1:${toString config.services.frr_exporter.port}/metrics";
            }];
          };
        } // lib.optionalAttrs config.boot.zfs.enabled {
          "go.d/zfspool.conf" = pkgs.writers.writeYAML "zfspool.conf" {
            jobs = [{
              name = "zfspool";
              binary_path = "${config.boot.zfs.package}/bin/zpool";
            }];
          };
        };
      };
    };

    systemd.services.netdata.serviceConfig.AmbientCapabilities = [
      "CAP_NET_RAW" # Required for ping collector
    ];

    networking.firewall.interfaces.${config.services.wireguard-network.interfaceName}.allowedTCPPorts = lib.mkIf isParent [ streamPort ];
  };
}
