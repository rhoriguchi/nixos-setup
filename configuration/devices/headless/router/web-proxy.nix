{ config, lib, interfaces, ... }:
let
  externalInterface = interfaces.external;
  internalInterface = interfaces.internal;

  serverIp = "192.168.2.2";
in {
  services.nginx = {
    enable = true;

    defaultSSLListenPort = 9443;

    streamConfig = let
      domains = lib.attrNames config.services.nginx.virtualHosts;
      localRoutings = map (domain: "${domain} ${config.networking.hostName};") domains;
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
        listen [::]:443;

        ssl_preread on;

        proxy_pass $name;
      }
    '';
  };

  networking.firewall.interfaces = let rules = { allowedTCPPorts = [ config.services.nginx.defaultHTTPListenPort 443 ]; };
  in {
    "${externalInterface}" = rules;

    "${internalInterface}" = rules;
    "${internalInterface}.1" = rules;
    "${internalInterface}.2" = rules;
    "${internalInterface}.3" = rules;
    "${internalInterface}.100" = rules;
  };
}
