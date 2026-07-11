{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  containerCfg = config.containers.deluge.config;

  parseWireguardConfig =
    file:
    let
      content = lib.readFile file;
      getValue =
        key:
        lib.pipe content [
          (lib.splitString "\n")

          (lib.findFirst (line: lib.hasPrefix key line) "")

          (lib.removePrefix "${key} = ")
        ];

      isIpv4 = string: !(lib.hasInfix ":" string);

      rawAddresses = lib.splitString ", " (getValue "Address");
      rawNameserver = lib.splitString ", " (getValue "DNS");
    in
    rec {
      privateKey = getValue "PrivateKey";
      publicKey = getValue "PublicKey";
      address = lib.head (lib.filter isIpv4 rawAddresses);
      endpoint = getValue "Endpoint";
      endpointIp = lib.head (lib.splitString ":" endpoint);
      nameserver = lib.head (lib.filter isIpv4 rawNameserver);
    };

  wgConfigDir = ./wireguard-configs;
  wgConfigFiles = lib.attrNames (lib.readDir wgConfigDir);
  wgConfigs = map (wgConfigFile: parseWireguardConfig "${wgConfigDir}/${wgConfigFile}") wgConfigFiles;

  wgInterfaces = lib.attrNames containerCfg.networking.wireguard.interfaces;
in
{
  assertions = [
    {
      assertion =
        lib.pipe wgConfigs [
          (map (wgConfig: wgConfig.nameserver))
          lib.unique
          lib.length
        ] == 1;
      message = "All WireGuard configurations must use the same nameserver.";
    }
  ];

  users = {
    users.${config.services.deluge.user} = {
      group = config.services.deluge.group;
      uid = config.ids.uids.deluge;
    };

    groups.${config.services.deluge.group}.gid = config.ids.gids.deluge;
  };

  systemd.tmpfiles.rules = [
    "d ${config.services.deluge.dataDir} 0750 ${config.services.deluge.user} ${config.services.deluge.group}"
  ];

  containers.deluge = {
    autoStart = true;
    ephemeral = true;

    privateNetwork = true;
    hostAddress = "169.254.1.1";
    localAddress = "169.254.1.41";

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

    config = {
      nixpkgs.pkgs = pkgs;
      system.stateVersion = config.system.stateVersion;

      boot.kernel.sysctl = lib.pipe wgInterfaces [
        (map (interface: lib.nameValuePair "net.ipv4.conf.${interface}.rp_filter" 2))

        lib.listToAttrs
      ];

      networking = {
        enableIPv6 = false;

        nameservers = lib.pipe wgConfigs [
          (map (wgConfig: wgConfig.nameserver))
          lib.unique
        ];

        localCommands = ''
          ${pkgs.iproute2}/bin/ip route del default || true
        '';

        wireguard.interfaces = lib.pipe wgConfigs [
          (lib.imap0 (
            index: wgConfig:
            lib.nameValuePair "wg${toString index}" {
              ips = [ wgConfig.address ];
              inherit (wgConfig) privateKey;

              allowedIPsAsRoutes = false;

              postSetup = ''
                # https://wiki.archlinux.org/title/WireGuard#Loop_routing
                ${pkgs.iproute2}/bin/ip route add ${wgConfig.endpointIp} via ${config.containers.deluge.hostAddress} dev eth0
              '';

              postShutdown = ''
                ${pkgs.iproute2}/bin/ip route del ${wgConfig.endpointIp} via ${config.containers.deluge.hostAddress} dev eth0
              '';

              peers = [
                {
                  inherit (wgConfig) publicKey;
                  allowedIPs = [ "0.0.0.0/0" ];
                  inherit (wgConfig) endpoint;

                  persistentKeepalive = 25;
                  dynamicEndpointRefreshSeconds = 30;
                }
              ];
            }
          ))

          lib.listToAttrs
        ];
      };

      systemd.services.wireguard-ecmp = {
        wants = [
          "network-online.target"
        ];
        after = [
          "network-online.target"
        ]
        ++ map (interface: "wireguard-${interface}.service") wgInterfaces;
        wantedBy = [ "network-online.target" ];

        script = ''
          update_routes() {
            nexthops=""

            for interface in ${lib.concatStringsSep " " wgInterfaces}; do
              if ${pkgs.iproute2}/bin/ip link show "$interface" 2>/dev/null | ${pkgs.gnugrep}/bin/grep -q "<.*UP.*>"; then
                nexthops="$nexthops nexthop dev $interface weight 1"
              fi
            done

            if [ -n "$nexthops" ]; then
              ${pkgs.iproute2}/bin/ip route replace default $nexthops
            else
              ${pkgs.iproute2}/bin/ip route del default 2>/dev/null || true
            fi
          }

          update_routes

          ${pkgs.iproute2}/bin/ip monitor link | while read line; do
            update_routes
          done
        '';

        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = "5s";
        };
      };

      services = {
        deluge = {
          enable = true;

          package = pkgs.deluge-2_x.overrideAttrs (oldAttrs: {
            patches = (oldAttrs.patches or [ ]) ++ [ ./remove-web-login.patch ];

            # TODO workaround for `ModuleNotFoundError: No module named 'pkg_resources'`
            # https://github.com/NixOS/nixpkgs/issues/540545
            propagatedBuildInputs = map (
              propagatedBuildInput:
              if (propagatedBuildInput.pname or "") == "setuptools" then
                pkgs.python314Packages.setuptools_80
              else
                propagatedBuildInput
            ) (oldAttrs.propagatedBuildInputs or [ ]);
          });

          web = {
            enable = true;
            openFirewall = true;
          };

          declarative = true;

          authFile = lib.pipe secrets.deluge.users [
            (lib.mapAttrsToList (key: value: "${key}:${value.password}:${toString value.level}"))

            (lib.concatStringsSep "\n")

            (pkgs.writeText "deluge-auth")
          ];

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
        acmeRoot = null;
        forceSSL = true;

        extraConfig = ''
          include /run/nginx-authelia/location.conf;
        '';

        locations."/" = {
          proxyPass = "http://${config.containers.deluge.localAddress}:${toString containerCfg.services.deluge.web.port}";

          extraConfig = ''
            include /run/nginx-authelia/auth.conf;
          '';
        };
      };
    };

    monitoring.extraPrometheusJobs = [
      {
        name = "Deluge";
        url = "http://${config.containers.deluge.localAddress}:${toString containerCfg.services.prometheus.exporters.deluge.port}/metrics";
      }
    ];
  };
}
