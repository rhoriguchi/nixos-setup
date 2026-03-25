{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  containerCfg = config.containers.deluge.config;

  wireguardInterface = "wg-deluge";

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

  wgConfig = parseWireguardConfig ./wireguard-config;
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

      networking = {
        nameservers = [ wgConfig.nameserver ];

        wireguard.interfaces.${wireguardInterface} = {
          ips = [ wgConfig.address ];
          inherit (wgConfig) privateKey;

          postSetup = ''
            # https://wiki.archlinux.org/title/WireGuard#Loop_routing
            ${pkgs.iproute2}/bin/ip route add ${wgConfig.endpointIp} via ${config.containers.deluge.hostAddress} dev eth0
          '';

          postShutdown = ''
            ${pkgs.iproute2}/bin/ip route del ${wgConfig.endpointIp} via ${config.containers.deluge.hostAddress} dev eth0
          '';

          peers = [
            {
              name = "Proton-VPN";

              inherit (wgConfig) publicKey;
              allowedIPs = [ "0.0.0.0/0" ];
              inherit (wgConfig) endpoint;

              persistentKeepalive = 25;
              dynamicEndpointRefreshSeconds = 30;
            }
          ];
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

          outgoing_interface = wireguardInterface;

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
