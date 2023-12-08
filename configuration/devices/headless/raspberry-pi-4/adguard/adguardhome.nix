{ pkgs, config, secrets, ... }: {
  services = {
    nginx = {
      enable = true;

      # TODO add certificate
      virtualHosts."adguardhome" = {
        # TODO commented
        # useACMEHost = null;

        # enableSSL = true;
        # forceSSL = true;

        listen = [{
          addr = "0.0.0.0";
          port = 80;
        }];

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.adguardhome.port}";
          proxyWebsockets = true;
        };

        extraConfig = ''
          allow 192.168.1.0/24;
          allow ${(import ../../../../../modules/default/wireguard-network/ips.nix).server};
          deny all;
        '';
      };
    };

    adguardhome = {
      enable = true;

      host = "127.0.0.1";

      mutableSettings = false;
      settings = assert pkgs.adguardhome.schema_version == 27;
        let
          routerIp = "192.168.1.1";
          ignored = [ "adguard.local" "infomaniak.com.local" "infomaniak.com" "unifi.local" "wireguard.00a.ch" ];
        in {
          users = [{
            name = secrets.adguard.username;
            password = secrets.adguard.encryptedUsernamePassword;
          }];

          dns = rec {
            bootstrap_dns = [ "tls://1.1.1.1" "tls://1.0.0.1" ];
            upstream_dns = bootstrap_dns ++ [ "[/guest/]${routerIp}" "[/iot/]${routerIp}" "[/local/]${routerIp}" ];
            rewrites = map (domain: {
              inherit domain;
              answer = "XXLPitu-Server.local";
            }) [
              "deluge.00a.ch"
              "home-assistant.00a.ch"
              "home.00a.ch"
              "minecraft.00a.ch"
              "prowlarr.00a.ch"
              "sonarr.00a.ch"
              "tautulli.00a.ch"
              "wireguard.00a.ch"
            ];

            ratelimit = 0;
          };

          querylog.ignored = ignored;
          statistics.ignored = ignored;
        };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 80 ];
    allowedUDPPorts = [ 53 ];
  };
}
