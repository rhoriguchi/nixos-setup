{ config, lib, interfaces, ... }:
let
  externalInterface = interfaces.external;
  internalInterface = interfaces.internal;

  serverDomains = [
    "deluge.00a.ch"
    "esphome.00a.ch"
    "grafana.00a.ch"
    "home-assistant.00a.ch"
    "immich.00a.ch"
    "minecraft.00a.ch"
    "monitoring.00a.ch"
    "prometheus.00a.ch"
    "prowlarr.00a.ch"
    "pushgateway.00a.ch"
    "sonarr.00a.ch"
    "tautulli.00a.ch"
  ];
  ulquiorraDomains = [ "printer.00a.ch" "scanner.00a.ch" ];

  getUpstreams = host: domains: lib.concatStringsSep "\n" (map (domain: "${domain} ${host};") domains);

  getVirtualHost = hostName: domains: {
    "${lib.replaceStrings [ ".local" ] [ "" ] hostName}" = {
      serverAliases = domains;

      listen = map (addr: {
        inherit addr;
        port = config.services.nginx.defaultHTTPListenPort;
      }) config.services.nginx.defaultListenAddresses;

      locations."/".proxyPass = "http://${hostName}:80";
    };
  };
in {
  networking.firewall.interfaces = let rules.allowedTCPPorts = [ config.services.nginx.defaultHTTPListenPort 443 ];
  in {
    "${externalInterface}" = rules;

    "${internalInterface}" = rules;
    "${internalInterface}.2" = rules;
    "${internalInterface}.3" = rules;
    "${internalInterface}.10" = rules;
    "${internalInterface}.100" = rules;
  };

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

        ${getUpstreams config.networking.hostName config.services.infomaniak.hostnames}
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

    virtualHosts = (getVirtualHost "XXLPitu-Server.local" serverDomains) // (getVirtualHost "XXLPitu-Ulquiorra.local" ulquiorraDomains);
  };
}
