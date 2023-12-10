{ pkgs, config, secrets, ... }: {
  networking.nameservers = [ "127.0.0.1" ];

  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "adguardhome.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."adguardhome.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.adguardhome.port}";
          proxyWebsockets = true;
        };
      };
    };

    adguardhome = {
      enable = true;

      host = "127.0.0.1";

      mutableSettings = false;
      settings = assert pkgs.adguardhome.schema_version == 27;
        let ignored = [ "infomaniak.com.local" "infomaniak.com" "ping.ui.com" "unifi.local" "wireguard.00a.ch" ];
        in {
          users = [{
            name = secrets.adguard.username;
            password = secrets.adguard.encryptedUsernamePassword;
          }];

          dns = rec {
            bootstrap_dns = [ "tls://1.1.1.1" "tls://1.0.0.1" ];
            upstream_dns = let routerIp = "192.168.1.1";
            in bootstrap_dns ++ [ "[/dmz/]${routerIp}" "[/guest/]${routerIp}" "[/iot/]${routerIp}" "[/local/]${routerIp}" ];

            ratelimit = 0;
          };

          filtering.rewrites = [{
            domain = "*.00a.ch";
            answer = "${config.networking.hostName}.dmz";
          }];

          querylog.ignored = ignored;
          statistics.ignored = ignored;
        };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
