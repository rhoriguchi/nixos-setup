{ config, pkgs, lib, ... }:
let
  cfg = config.services.monitoring;

  streamPort = 19996;

  isParent = cfg.type == "parent";
  isChild = cfg.type == "child";

  wireguardIps = import ./wireguard-network/ips.nix;
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

      netdata = {
        enable = true;

        package = pkgs.netdata.override { withCloudUi = isParent; };

        # TODO monitor
        # CUPS https://learn.netdata.cloud/docs/collecting-metrics/hardware-devices-and-sensors/cups
        # Dnsmasq DHCP https://learn.netdata.cloud/docs/collecting-metrics/dns-and-dhcp-servers/dnsmasq-dhcp
        # Dnsmasq https://learn.netdata.cloud/docs/collecting-metrics/dns-and-dhcp-servers/dnsmasq
        # HDD temperature https://learn.netdata.cloud/docs/collecting-metrics/hardware-devices-and-sensors/hdd-temperature
        # Minecraft https://www.netdata.cloud/integrations/data-collection/gaming/minecraft/
        # Nvidia GPU https://learn.netdata.cloud/docs/collecting-metrics/hardware-devices-and-sensors/nvidia-gpu
        # S.M.A.R.T. https://learn.netdata.cloud/docs/collecting-metrics/hardware-devices-and-sensors/s.m.a.r.t.

        # TODO install on windows (Plugin: go.d.plugin Module: windows)

        config = {
          parent.web = {
            "bind to" = lib.concatStringsSep " " [
              "127.0.0.1:${toString cfg.webPort}=dashboard|registry|badges|management|netdata.conf"
              "${wireguardIps.${config.networking.hostName}}:${toString streamPort}=streaming"
            ];

            "enable gzip compression" = "no";
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
        } // lib.optionalAttrs config.services.nginx.enable {
          "go.d/nginx.conf" = (pkgs.formats.yaml { }).generate "nginx.conf" {
            jobs = [{
              name = "local";
              url = "http://localhost/nginx_status";
            }];
          };
        };
      };
    };

    systemd.services.netdata.serviceConfig = {
      AmbientCapabilities = [
        "CAP_NET_ADMIN" # Required for WireGuard collector https://github.com/NixOS/nixpkgs/pull/298641#issuecomment-2103671221
      ];

      CapabilityBoundingSet = [
        "CAP_NET_ADMIN" # Required for WireGuard collector https://github.com/NixOS/nixpkgs/pull/298641#issuecomment-2103671221
      ];
    };

    networking.firewall.interfaces.${config.services.wireguard-network.interfaceName}.allowedTCPPorts = lib.mkIf isParent [ streamPort ];
  };
}
