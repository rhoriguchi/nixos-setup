{
  config,
  lib,
  libCustom,
  ...
}:
let
  ips = import (libCustom.relativeToRoot "configuration/devices/headless/urahara/dhcp/ips.nix");

  tierDomains = [
    "authelia.00a.ch"
    "bazarr.00a.ch"
    "deluge.00a.ch"
    "grafana.00a.ch"
    "home-assistant.00a.ch"
    "jellyfin.00a.ch"
    "minecraft.00a.ch"
    "monitoring.00a.ch"
    "prometheus.00a.ch"
    "prowlarr.00a.ch"
    "radarr.00a.ch"
    "rustdesk.00a.ch"
    "sonarr.00a.ch"
    "syncthing-relay.00a.ch"
    "tautulli.00a.ch"
    "webdav.00a.ch"
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
        ipv4 = "127.0.0.1:${toString config.services.nginx.defaultSSLListenPort}";
        ipv6 = lib.mkIf config.networking.enableIPv6 "[::1]:${toString config.services.nginx.defaultSSLListenPort}";
        hostnames = config.services.infomaniak.hostnames;
      };

      XXLPitu-Tier = {
        ipv4 = "${ips.tier}:443";
        hostnames = tierDomains;
      };
    };

    virtualHosts = (getVirtualHost "XXLPitu-Tier.local" ips.tier tierDomains);
  };
}
