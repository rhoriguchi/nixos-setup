{ config, lib, nodes, ... }:
let
  localDomains = config.services.infomaniak.hostnames;
  serverDomains = nodes.Server.config.services.infomaniak.hostnames;
  ulquiorraDomains = nodes.Ulquiorra.config.services.infomaniak.hostnames;

  getUpstreams = host: domains: lib.concatStringsSep "\n" (map (domain: "${domain} ${host};") domains);

  getVirtualHosts = hostName: domains:
    lib.listToAttrs (map (domain:
      lib.nameValuePair domain {
        listen = map (addr: {
          inherit addr;
          port = config.services.nginx.defaultHTTPListenPort;
        }) config.services.nginx.defaultListenAddresses;

        locations."/".proxyPass = "http://${hostName}:80";
      }) domains);
in {
  # nginx needs to start after adguardhome because of `resolver` option
  systemd.services = {
    nginx.after = lib.optional config.services.adguardhome.enable "adguardhome.service";
    nginx-config-reload.after = lib.optional config.services.adguardhome.enable "adguardhome.service";
  };

  services.nginx = {
    enable = true;

    defaultSSLListenPort = 9443;

    streamConfig = ''
      resolver 127.0.0.1;

      upstream ${config.networking.hostName} {
        server 127.0.0.1:${toString config.services.nginx.defaultSSLListenPort};
      }

      upstream lancache {
        server 127.0.0.1:${toString config.services.lancache.httpsPort};
      }

      upstream XXLPitu-Ulquiorra {
        server XXLPitu-Ulquiorra.local:443;
      }

      upstream XXLPitu-Server {
        server XXLPitu-Server.local:443;
      }

      map $ssl_preread_server_name $upstream {
        # indicates that source values can be hostnames with a prefix or suffix mask:
        hostnames;

        ${getUpstreams config.networking.hostName localDomains}
        ${getUpstreams "lancache" config.services.lancache.cacheDomains}

        ${getUpstreams "XXLPitu-Server" serverDomains}
        ${getUpstreams "XXLPitu-Ulquiorra" ulquiorraDomains}
      }

      server {
        listen 443;
        ${lib.optionalString config.networking.enableIPv6 "listen [::]:443;"}

        ssl_preread on;

        proxy_pass $upstream;
      }
    '';

    virtualHosts = (getVirtualHosts "XXLPitu-Server.local" serverDomains) // (getVirtualHosts "XXLPitu-Ulquiorra.local" ulquiorraDomains);
  };
}
