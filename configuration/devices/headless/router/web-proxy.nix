{ config, lib, ... }: {
  services.nginx = {
    enable = true;

    defaultSSLListenPort = 9443;

    streamConfig = let
      domains = lib.attrNames config.services.nginx.virtualHosts;
      localRoutings = map (domain: "${domain} ${config.networking.hostName};") (lib.filter (domain: domain != "*.00a.ch") domains);
    in ''
      resolver 127.0.0.1;

      upstream ${config.networking.hostName} {
        server 127.0.0.1:${toString config.services.nginx.defaultSSLListenPort};
      }

      upstream XXLPitu-Server {
        server XXLPitu-Server.local:443;
      }

      map $ssl_preread_server_name $upstream {
        ${lib.concatStringsSep "\n" localRoutings}
        default XXLPitu-Server;
      }

      server {
        listen 443;
        ${lib.optionalString config.networking.enableIPv6 "listen [::]:443;"}

        ssl_preread on;

        proxy_pass $upstream;
      }
    '';

    virtualHosts."*.00a.ch" = {
      listen = map (addr: {
        inherit addr;
        port = config.services.nginx.defaultHTTPListenPort;
      }) config.services.nginx.defaultListenAddresses;

      locations."/".proxyPass = "http://XXLPitu-Server.local:80";
    };
  };
}
