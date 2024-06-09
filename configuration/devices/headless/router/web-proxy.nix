{ config, lib, ... }:
let serverIp = "192.168.2.2";
in {
  services.nginx = {
    enable = true;

    defaultSSLListenPort = 9443;

    streamConfig = let
      domains = lib.attrNames config.services.nginx.virtualHosts;
      localRoutings = map (domain: "${domain} ${config.networking.hostName};") (lib.filter (domain: domain != "*.00a.ch") domains);
    in ''
      upstream ${config.networking.hostName} {
        server 127.0.0.1:${toString config.services.nginx.defaultSSLListenPort};
      }

      upstream XXLPitu-Server {
        server ${serverIp}:443;
      }

      map $ssl_preread_server_name $name {
        ${lib.concatStringsSep "\n" localRoutings}
        default XXLPitu-Server;
      }

      server {
        listen 443;
        ${lib.optionalString config.networking.enableIPv6 "listen [::]:443;"}

        ssl_preread on;

        proxy_pass $name;
      }
    '';

    virtualHosts."*.00a.ch" = {
      listen = map (addr: {
        inherit addr;
        port = 80;
      }) config.services.nginx.defaultListenAddresses;

      locations."/".proxyPass = "http://${serverIp}:80";
    };
  };
}
