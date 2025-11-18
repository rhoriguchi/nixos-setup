{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.monitoring;

  streamPort = 19996;

  isParent = cfg.type == "parent";
  isChild = cfg.type == "child";

  tailscaleIps = import (
    lib.custom.relativeToRoot "configuration/devices/headless/nelliel/headscale/ips.nix"
  );

  keaEnabled = lib.any (service: service.enable) [
    config.services.kea.dhcp4
    config.services.kea.dhcp6
  ];

  redisEnabled = lib.any (server: server.enable) (lib.attrValues config.services.redis.servers);

  hasCerts = lib.attrNames config.security.acme.certs != [ ];
in
{
  options.services.monitoring = {
    enable = lib.mkEnableOption "Monitoring with Netdata";
    type = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "parent"
          "child"
        ]
      );
    };
    parentHostname = lib.mkOption { type = lib.types.nullOr lib.types.str; };
    apiKey = lib.mkOption { type = lib.types.str; };
    claimToken = lib.mkOption { type = lib.types.nullOr lib.types.str; };
    discordWebhookUrl = lib.mkOption { type = lib.types.nullOr lib.types.str; };
    webPort = lib.mkOption {
      type = lib.types.port;
      default = 19999;
    };
    debug = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
      };
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "tailscale service must be enabled";
      }
      {
        assertion = isParent -> lib.elem config.networking.hostName (lib.attrNames tailscaleIps);
        message = "When type is parent hostname must be tailscale host";
      }
      {
        assertion = isParent -> cfg.discordWebhookUrl != null;
        message = "When type is parent discordWebhookUrl must be set";
      }
      {
        assertion = isParent -> cfg.claimToken != null;
        message = "When type is parent claimToken must be set";
      }
      {
        assertion = isChild -> cfg.parentHostname != null;
        message = "When type is child parentHostname must be set";
      }
      {
        assertion = isChild -> lib.elem cfg.parentHostname (lib.attrNames tailscaleIps);
        message = "When type is child parentHostname must be tailscale host";
      }
    ];

    services = {
      bind.extraConfig = ''
        statistics-channels {
          inet 127.0.0.1 port 8653 allow { 127.0.0.1; };
        };
      '';

      borg-exporter.enable = config.services.borgmatic.enable;

      corerad.settings.debug = {
        address = "127.0.0.1:9430";
        prometheus = true;
      };

      loki.configuration.server.register_instrumentation = true;

      mysql.ensureUsers = [
        {
          name = "netdata";
          ensurePermissions."*.*" = lib.concatStringsSep ", " [
            "PROCESS"
            "REPLICATION CLIENT"
            "USAGE"
          ];
        }
      ];

      nginx.statusPage = true;

      # TODO workaround for https://github.com/NixOS/nixpkgs/issues/204189
      postgresql.initialScript = pkgs.writeText "initialScript" ''
        CREATE USER netdata;
        GRANT pg_monitor TO netdata;
      '';

      prometheus.exporters = {
        exportarr-sonarr = {
          enable = config.services.sonarr.enable;

          port = 9708;

          url = "http://127.0.0.1:${toString config.services.sonarr.settings.server.port}";

          environment.INTERFACE = "127.0.0.1";
        };

        exportarr-prowlarr = {
          enable = config.services.prowlarr.enable;

          port = 9709;

          url = "http://127.0.0.1:${toString config.services.prowlarr.settings.server.port}";

          environment = {
            INTERFACE = "127.0.0.1";

            PROWLARR__BACKFILL = "true";
          };
        };

        frr =
          let
            collectors = [
              "bfd"
              "bgp"
              "bgp6"
              "bgpl2vpn"
              "ospf"
              "pim"
              "route"
              "vrrp"
            ];

            enabledCollectors =
              lib.optional config.services.frr.bfdd.enable "bfd"
              ++ lib.optionals config.services.frr.bgpd.enable (
                [
                  "bgp"
                  "bgpl2vpn"
                ]
                ++ lib.optional config.networking.enableIPv6 "bgp6"
              )
              ++ lib.optional (config.services.frr.ospfd.enable || config.services.frr.ospf6d.enable) "ospf"
              ++ lib.optional config.services.frr.pimd.enable "pim"
              ++ lib.optional (lib.any (module: module ? enable && module.enable == true) (
                lib.attrValues (
                  # Filter all keys that where renamed or removed
                  lib.filterAttrs (
                    key: _:
                    !(lib.elem key [
                      "babel"
                      "bfd"
                      "bgp"
                      "eigrp"
                      "fabric"
                      "isis"
                      "ldp"
                      "mgmt"
                      "nhrp"
                      "ospf"
                      "ospf6"
                      "pbr"
                      "pim"
                      "rip"
                      "ripng"
                      "sharp"
                      "static"
                      "zebra"
                    ])
                  ) config.services.frr
                )
              )) "route"
              ++ lib.optional config.services.frr.vrrpd.enable "vrrp";
          in
          {
            enable = lib.length enabledCollectors > 0;

            port = 9342;
            listenAddress = "127.0.0.1";

            group = "frrvty";

            inherit enabledCollectors;
            disabledCollectors = lib.filter (collector: !(lib.elem collector enabledCollectors)) collectors;
          };

        kea = {
          enable = keaEnabled;

          targets =
            lib.optional config.services.kea.dhcp4.enable "/run/kea/kea-dhcp4.socket"
            ++ lib.optional config.services.kea.dhcp6.enable "/run/kea/kea-dhcp6.socket";
        };
      };

      headscale.settings.metrics_listen_addr = "127.0.0.1:9090";

      kea = {
        dhcp4.settings.control-socket = {
          socket-type = "unix";
          socket-name = "/run/kea/kea-dhcp4.socket";
        };

        dhcp6.settings.control-socket = {
          socket-type = "unix";
          socket-name = "/run/kea/kea-dhcp6.socket";
        };

        ctrl-agent = {
          enable = keaEnabled;

          settings = {
            http-host = "127.0.0.1";
            http-port = 8000;

            control-sockets =
              lib.optionalAttrs config.services.kea.dhcp4.enable {
                dhcp4 = {
                  socket-type = "unix";
                  socket-name = "/run/kea/kea-dhcp4.socket";
                };
              }
              // lib.optionalAttrs config.services.kea.dhcp6.enable {
                dhcp6 = {
                  socket-type = "unix";
                  socket-name = "/run/kea/kea-dhcp6.socket";
                };
              };
          };
        };
      };

      promtail.configuration.server.register_instrumentation = true;

      samba.settings.global."smbd profiling level" = "count";

      netdata = {
        enable = true;

        package = pkgs.netdata.override {
          withCloudUi = isParent;
          withCups = true;
          withDBengine = isParent;
          withDebug = cfg.debug.enable;
          withLibbacktrace = cfg.debug.enable;
          withML = isParent;
          withNdsudo = true;
          withOtel = false;
          withSystemdJournal = false;
        };

        claimTokenFile = if isParent then pkgs.writeText "claimToken" cfg.claimToken else null;

        extraNdsudoPackages = [
          # Optical modules collector
          pkgs.ethtool

          # NVMe devices collector
          pkgs.nvme-cli

          # S.M.A.R.T. collector
          pkgs.smartmontools
        ]
        ++ lib.optional config.services.fail2ban.enable config.services.fail2ban.package
        ++ lib.optional config.services.samba.enable config.services.samba.package;

        config =
          {
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
                  "${tailscaleIps.${config.networking.hostName}}:${toString streamPort}=streaming"
                ];

                "enable gzip compression" = "no";
              };
            };

            child = {
              db.mode = "ram";

              web.mode = "none";
            };
          }
          .${cfg.type};

        configDir = {
          "stream.conf" =
            (pkgs.formats.ini { }).generate "stream.conf"
              {
                parent.${cfg.apiKey}.enabled = "yes";

                child.stream = {
                  enabled = "yes";

                  "api key" = cfg.apiKey;
                  destination = "${tailscaleIps.${cfg.parentHostname}}:${toString streamPort}";
                };
              }
              .${cfg.type};
        }
        // lib.optionalAttrs config.services.bind.enable {
          "go.d/bind.conf" = pkgs.writers.writeYAML "bind.conf" {
            jobs = [
              {
                name = "local";
                url = "http://127.0.0.1:8653/xml/v3";
              }
            ];
          };
        }
        // lib.optionalAttrs config.services.dnsmasq.enable {
          "go.d/dnsmasq_dhcp.conf" = pkgs.writers.writeYAML "dnsmasq_dhcp.conf" {
            jobs = [
              {
                name = "local";
                leases_path = "/var/lib/dnsmasq/dnsmasq.leases";
                conf_path = config.services.dnsmasq.finalConfigFile;
              }
            ];
          };
        }
        // lib.optionalAttrs config.services.dnsmasq.enable {
          "go.d/dnsmasq.conf" = pkgs.writers.writeYAML "dnsmasq.conf" {
            jobs = [
              {
                name = "local";
                address = "127.0.0.1:${toString config.services.dnsmasq.settings.port}";
              }
            ];
          };
        }
        // lib.optionalAttrs config.services.fail2ban.enable {
          "go.d/fail2ban.conf" = pkgs.writers.writeYAML "fail2ban.conf" { jobs = [ { name = "local"; } ]; };
        }
        // lib.optionalAttrs config.services.nginx.enable {
          "go.d/nginx.conf" = pkgs.writers.writeYAML "nginx.conf" {
            jobs = [
              {
                name = "nginx";
                url = "http://127.0.0.1/nginx_status";
              }
            ];
          };
        }
        // {
          "go.d/nvme.conf" = pkgs.writers.writeYAML "nvme.conf" { jobs = [ { name = "local"; } ]; };
        }
        // lib.optionalAttrs redisEnabled {
          "go.d/redis.conf" = pkgs.writers.writeYAML "redis.conf" {
            jobs = lib.mapAttrsToList (key: value: {
              name = key;
              address = "unix://@${value.unixSocket}";
            }) config.services.redis.servers;
          };
        }
        // {
          "go.d/smartctl.conf" = pkgs.writers.writeYAML "smartctl.conf" { jobs = [ { name = "local"; } ]; };
        }
        // {
          "go.d/sensors.conf" = pkgs.writers.writeYAML "sensors.conf" {
            jobs = [
              {
                name = "local";
                binary_path = "${pkgs.lm_sensors}/bin/sensors";
              }
            ];
          };
        }
        // {
          "go.d/prometheus.conf" = pkgs.writers.writeYAML "prometheus.conf" {
            jobs =
              lib.optional config.services.borg-exporter.enable {
                name = "Borg";
                url = "http://127.0.0.1:${toString config.services.borg-exporter.port}/metrics";
              }
              ++ lib.optional config.services.corerad.enable {
                name = "CoreRAD";
                url = "http://${config.services.corerad.settings.debug.address}/metrics";
              }
              ++ lib.optional config.services.flaresolverr.prometheusExporter.enable {
                name = "FlareSolverr";
                url = "http://127.0.0.1:${toString config.services.flaresolverr.prometheusExporter.port}/metrics";
              }
              ++ lib.optional config.services.prometheus.exporters.frr.enable {
                name = "FRRouting";
                url = "http://127.0.0.1:${toString config.services.prometheus.exporters.frr.port}/metrics";
              }
              ++ lib.optional config.services.grafana.enable {
                name = "Grafana";
                url = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}/metrics";
              }
              ++ lib.optional config.services.headscale.enable {
                name = "Headscale";
                url = "http://${config.services.headscale.settings.metrics_listen_addr}/metrics";
              }
              ++ lib.optional config.services.prometheus.exporters.kea.enable {
                name = "Kea";
                url = "http://127.0.0.1:${toString config.services.prometheus.exporters.kea.port}/metrics";
              }
              ++ lib.optional config.services.loki.enable {
                name = "Loki";
                url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/metrics";
              }
              ++ lib.optional config.services.minecraft-servers.enable {
                name = "Minecraft";
                url = "http://127.0.0.1:9940/metrics";
              }
              ++ lib.optional config.services.promtail.enable {
                name = "Promtail";
                url = "http://127.0.0.1:${toString config.services.promtail.configuration.server.http_listen_port}/metrics";
              }
              ++ lib.optional config.services.prometheus.exporters.exportarr-prowlarr.enable {
                name = "Prowlarr";
                url = "http://127.0.0.1:${toString config.services.prometheus.exporters.exportarr-prowlarr.port}/metrics";
              }
              ++ lib.optional config.services.prometheus.exporters.exportarr-sonarr.enable {
                name = "Sonarr";
                url = "http://127.0.0.1:${toString config.services.prometheus.exporters.exportarr-sonarr.port}/metrics";
              }
              ++ lib.optional config.services.tailscale.enable {
                name = "Tailscale Client";
                url = "http://100.100.100.100/metrics";
              }
              ++ lib.optional config.services.tailscale.derper.enable {
                name = "Tailscale Embedded DERP";
                url = "http://127.0.0.1:${toString config.services.tailscale.derper.port}/debug/varz";
              }
              ++ lib.optional config.services.unpoller.enable {
                name = "Unpoller";
                url = "http://${config.services.unpoller.prometheus.http_listen}/metrics";
              }
              ++ lib.optional config.services.uptime-kuma.enable {
                name = "Uptime Kuma";
                url = "http://127.0.0.1:${toString config.services.uptime-kuma.settings.PORT}/metrics";
              };
          };
        }
        // lib.optionalAttrs hasCerts {
          "go.d/x509check.conf" = pkgs.writers.writeYAML "x509check.conf" {
            jobs = map (hostname: {
              name = lib.replaceStrings [ "." ] [ "_" ] hostname;
              source = "file:///var/lib/acme/${hostname}/cert.pem";
            }) (lib.attrNames config.security.acme.certs);
          };
        }
        // lib.optionalAttrs config.boot.zfs.enabled {
          "go.d/zfspool.conf" = pkgs.writers.writeYAML "zfspool.conf" {
            jobs = [
              {
                name = "local";
                binary_path = "${config.boot.zfs.package}/bin/zpool";
              }
            ];
          };
        }
        // lib.optionalAttrs isParent {
          "health_alarm_notify.conf" = pkgs.writeTextFile {
            name = "health_alarm_notify.conf";
            text = ''
              SEND_DISCORD="YES"
              DISCORD_WEBHOOK_URL="${cfg.discordWebhookUrl}"
              DEFAULT_RECIPIENT_DISCORD="netdata"
            '';
          };
        };
      };
    };

    systemd.services = {
      netdata = {
        requires = [ config.systemd.services.netdata-set-node-uuid.name ];

        serviceConfig = {
          CapabilityBoundingSet = [
            # S.M.A.R.T. collector
            "CAP_SYS_RAWIO"
          ];

          AmbientCapabilities = [
            # Ping collector
            "CAP_NET_RAW"
          ];
        };
      };

      netdata-set-node-uuid = {
        before = [ config.systemd.services.netdata.name ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig.Type = "oneshot";

        script = ''
          mkdir -p /var/lib/netdata/registry

          hash=$(echo -n "${config.networking.hostName}" | sha1sum | ${pkgs.gawk}/bin/awk '{print $1}')
          printf "%s-%s-%s-%s-%s" \
            "''${hash:0:8}" \
            "''${hash:8:4}" \
            "''${hash:12:4}" \
            "''${hash:16:4}" \
            "''${hash:20:12}" > /var/lib/netdata/registry/netdata.public.unique.id

          chown -R ${config.services.netdata.user}:${config.services.netdata.group} /var/lib/netdata/registry
        '';
      };
    };

    users.users.${config.services.netdata.user}.extraGroups =
      # Redis collector
      lib.optionals redisEnabled (
        map (server: server.group) (lib.attrValues config.services.redis.servers)
      )

      # Web server collector
      ++ lib.optional config.services.nginx.enable config.services.nginx.group

      # X.509 certificate collector
      ++ (
        let
          acmeGroups = lib.unique (map (acme: acme.group) (lib.attrValues config.security.acme.certs));
        in
        lib.optionals hasCerts acmeGroups
      );

    networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts =
      lib.mkIf isParent
        [ streamPort ];
  };
}
