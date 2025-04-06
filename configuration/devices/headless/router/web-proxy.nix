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

  services.nginx = {
    enable = true;

    defaultSSLListenPort = 9443;

    stream.upstreams = {
      "${config.networking.hostName}" = {
        server = "127.0.0.1:${toString config.services.nginx.defaultSSLListenPort}";
        hostnames = config.services.infomaniak.hostnames;
      };

      XXLPitu-Ulquiorra = {
        server = "XXLPitu-Ulquiorra.local:443";
        hostnames = ulquiorraDomains;
      };

      XXLPitu-Server = {
        server = "XXLPitu-Server.local:443";
        hostnames = serverDomains;
      };
    };

    virtualHosts = (getVirtualHost "XXLPitu-Server.local" serverDomains) // (getVirtualHost "XXLPitu-Ulquiorra.local" ulquiorraDomains);
  };
}
