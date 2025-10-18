{ config, lib, ... }:
let
  ips = import (lib.custom.relativeToRoot "configuration/devices/headless/router/dhcp/ips.nix");

  serverDomains = [
    "deluge.00a.ch"
    "grafana.00a.ch"
    "home-assistant.00a.ch"
    "minecraft.00a.ch"
    "monitoring.00a.ch"
    "prometheus.00a.ch"
    "prowlarr.00a.ch"
    "sonarr.00a.ch"
    "tautulli.00a.ch"
  ];
  ulquiorraDomains = [
    "printer.00a.ch"
    "scanner.00a.ch"
  ];

  getVirtualHost = name: ip: domains: {
    "${name}" = {
      serverAliases = domains;

      listen = map (addr: {
        inherit addr;
        port = config.services.nginx.defaultHTTPListenPort;
      }) config.services.nginx.defaultListenAddresses;

      locations."/".proxyPass = "http://${ip}:80";
    };
  };
in
{
  networking.firewall.allowedTCPPorts = [
    config.services.nginx.defaultHTTPListenPort
    443
  ];

  services.nginx = {
    enable = true;

    stream.upstreams = {
      "${config.networking.hostName}" = {
        server = "127.0.0.1:${toString config.services.nginx.defaultSSLListenPort}";
        hostnames = config.services.infomaniak.hostnames;
      };

      XXLPitu-Ulquiorra = {
        server = "${ips.ulquiorra}:443";
        hostnames = ulquiorraDomains;
      };

      XXLPitu-Tier = {
        server = "${ips.tier}:443";
        hostnames = serverDomains;
      };
    };

    virtualHosts =
      (getVirtualHost "XXLPitu-Tier.local" ips.tier serverDomains)
      // (getVirtualHost "XXLPitu-Ulquiorra.local" ips.ulquiorra ulquiorraDomains);
  };
}
