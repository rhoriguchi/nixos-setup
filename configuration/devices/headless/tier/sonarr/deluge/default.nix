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
        let
          lines = lib.splitString "\n" content;
          matchingLine = lib.findFirst (line: lib.hasPrefix key line) "" lines;
        in
        lib.removePrefix "${key} = " matchingLine;

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
  users = {
    users.${config.services.deluge.user} = {
      group = config.services.deluge.group;
      uid = config.ids.uids.deluge;
      home = config.services.deluge.dataDir;
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

    config = {
      nixpkgs.pkgs = pkgs;
      system.stateVersion = config.system.stateVersion;

      boot.kernel.sysctl = lib.listToAttrs (
        map (interface: lib.nameValuePair "net.ipv4.conf.${interface}.rp_filter" 2) wgInterfaces
      );

      networking = {
        enableIPv6 = false;

        nameservers =
          let
            wgNameservers = map (wgConfig: wgConfig.nameserver) wgConfigs;
          in
          assert lib.length (lib.unique (wgNameservers)) == 1;
          lib.unique wgNameservers;

        localCommands = ''
          ${pkgs.iproute2}/bin/ip route del default || true
        '';

        wireguard.interfaces = lib.listToAttrs (
          lib.imap0 (
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
          ) wgConfigs
        );
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

      services.deluge = {
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

          enabled_plugins = [
            "Label"
          ];
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
  };
}
