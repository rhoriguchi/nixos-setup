{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  containerCfg = config.containers.deluge.config;
in
{
  users = {
    users.${config.services.deluge.user} = {
      group = config.services.deluge.group;
      uid = config.ids.uids.deluge;
      home = config.services.deluge.dataDir;
    };

    groups.${config.services.deluge.group}.gid = config.ids.gids.deluge;
  };

  systemd.tmpfiles.rules = [
    "d ${config.services.deluge.dataDir} 0550 ${config.services.deluge.user} ${config.services.deluge.group}"
  ];

  containers.deluge = {
    autoStart = true;
    ephemeral = true;

    privateNetwork = true;
    hostAddress = "169.254.1.1";
    localAddress = "169.254.1.2";

    bindMounts = {
      "${config.services.deluge.dataDir}" = {
        isReadOnly = false;
        hostPath = containerCfg.services.deluge.dataDir;
      };

      "/mnt/Data/Deluge" = {
        isReadOnly = false;
        hostPath = "/mnt/Data/Deluge";
      };
    };

    config =
      let
        wireguardInterface = "wg-deluge";

        getValue =
          string: key:
          let
            lines = lib.splitString "\n" string;
            matchingLine = lib.findFirst (line: lib.hasPrefix key line) "" lines;
          in
          lib.removePrefix "${key} = " matchingLine;

        configText = lib.readFile ./wireguard-config;

        privateKey = getValue configText "PrivateKey";
        publicKey = getValue configText "PublicKey";
        ipCdr = getValue configText "Address";
        endpoint = getValue configText "Endpoint";
        endpointIp = lib.head (lib.splitString ":" endpoint);
        nameserver = getValue configText "DNS";
      in
      {
        system = {
          inherit (config.system) stateVersion;
        };

        networking = {
          nameservers = [ nameserver ];

          wireguard.interfaces.${wireguardInterface} = {
            ips = [ "${ipCdr}" ];
            inherit privateKey;

            postSetup = ''
              # https://wiki.archlinux.org/title/WireGuard#Loop_routing
              ${pkgs.iproute2}/bin/ip route add ${endpointIp} via ${config.containers.deluge.hostAddress} dev eth0
            '';

            postShutdown = ''
              ${pkgs.iproute2}/bin/ip route del ${endpointIp} via ${config.containers.deluge.hostAddress} dev eth0
            '';

            peers = [
              {
                name = "Proton-VPN";

                inherit publicKey;
                allowedIPs = [ "0.0.0.0/0" ];
                inherit endpoint;

                persistentKeepalive = 25;
                dynamicEndpointRefreshSeconds = 30;
              }
            ];
          };
        };

        services = {
          deluge = {
            enable = true;

            package = pkgs.deluge.overrideAttrs (oldAttrs: {
              patches = (oldAttrs.patches or [ ]) ++ [ ./remove-web-login.patch ];
            });

            web = {
              enable = true;
              openFirewall = true;
            };

            declarative = true;

            authFile =
              let
                text = lib.concatStringsSep "\n" (
                  lib.mapAttrsToList (
                    key: value: "${key}:${value.password}:${toString value.level}"
                  ) secrets.deluge.users
                );
              in
              pkgs.writeText "deluge-auth" text;

            config = rec {
              new_release_check = false;

              download_location = "/mnt/Data/Deluge/Downloads";

              copy_torrent_file = true;
              torrentfiles_location = "/mnt/Data/Deluge/Torrents";

              stop_seed_at_ratio = true;
              stop_seed_ratio = 0.0;

              max_active_downloading = 10;
              max_active_seeding = 10;
              max_active_limit = max_active_downloading + max_active_seeding;

              queue_new_to_top = true;
              dont_count_slow_torrents = true;

              outgoing_interface = wireguardInterface;

              enabled_plugins = [
                "Label"
              ];
            };
          };

          prometheus.exporters.deluge = {
            enable = true;

            openFirewall = true;

            delugeUser = "metrics";
            delugePasswordFile = pkgs.writeText "deluge-metrics-password" secrets.deluge.users.metrics.password;
          };
        };
      };
  };

  services = {
    monitoring.extraPrometheusJobs = [
      {
        name = "Deluge";
        url = "http://${config.containers.deluge.localAddress}:${toString containerCfg.services.prometheus.exporters.deluge.port}/metrics";
      }
    ];

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "deluge.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."deluge.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        extraConfig = ''
          include /run/nginx-authelia/location.conf;
        '';

        locations."/" = {
          proxyPass = "http://${config.containers.deluge.localAddress}:${toString containerCfg.services.deluge.web.port}";

          extraConfig = ''
            include /run/nginx-authelia/auth.conf;

            satisfy any;
            allow 192.168.2.0/24;
            deny all;
          '';
        };
      };
    };
  };
}
