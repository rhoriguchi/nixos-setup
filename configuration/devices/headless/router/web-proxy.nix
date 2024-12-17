{ config, lib, ... }:
let
  getRoutings = host: domains:
    let getRouting = host: domain: "${domain} ${host};";
    in lib.concatStringsSep "\n" (map (domain: getRouting host domain) domains);

  getVirtualHosts = hostName: domains:
    lib.listToAttrs (map (domain:
      lib.nameValuePair domain {
        listen = map (addr: {
          inherit addr;
          port = config.services.nginx.defaultHTTPListenPort;
        }) config.services.nginx.defaultListenAddresses;

        locations."/".proxyPass = "http://${hostName}:80";
      }) domains);

  ulquiorraDomains = [ "scanner.00a.ch" ];
  serverDomains = [ "*.00a.ch" ];

  localDomains = let filter = virtualHost: builtins.all (domain: virtualHost != domain) (ulquiorraDomains ++ serverDomains);
  in lib.filter filter (lib.attrNames config.services.nginx.virtualHosts);
in {
  # nginx needs to start after adguardhome because of `resolver` option
  systemd.services.nginx.after = lib.optional config.services.adguardhome.enable "adguardhome.service";

  services.nginx = {
    enable = true;

    defaultSSLListenPort = 9443;

    streamConfig = ''
      resolver 127.0.0.1;

      upstream ${config.networking.hostName} {
        server 127.0.0.1:${toString config.services.nginx.defaultSSLListenPort};
      }

      upstream XXLPitu-Ulquiorra {
        server XXLPitu-Ulquiorra.local:443;
      }

      upstream XXLPitu-Server {
        server XXLPitu-Server.local:443;
      }

      map $ssl_preread_server_name $upstream {
        ${getRoutings config.networking.hostName localDomains}
        ${getRoutings "XXLPitu-Ulquiorra" ulquiorraDomains}

        default XXLPitu-Server;
      }

      server {
        listen 443;
        ${lib.optionalString config.networking.enableIPv6 "listen [::]:443;"}

        ssl_preread on;

        proxy_pass $upstream;
      }
    '';

    virtualHosts = (getVirtualHosts "XXLPitu-Ulquiorra.local" ulquiorraDomains) // (getVirtualHosts "XXLPitu-Server.local" serverDomains);
  };
}
