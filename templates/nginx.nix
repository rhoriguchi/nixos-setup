{ lib, config, ... }:
let
  nginxEnabled = config.services.nginx.enable;
  nginxVirtualHostValues = lib.attrValues config.services.nginx.virtualHosts;

  virtualHostsWithAcme = lib.filter (virtualHost: virtualHost.enableACME) nginxVirtualHostValues;
  openPort80 = nginxEnabled && lib.length virtualHostsWithAcme > 0;

  virtualHostWithSSL = lib.filter (virtualHost: virtualHost.addSSL || virtualHost.enableSSL || virtualHost.forceSSL || virtualHost.onlySSL)
    nginxVirtualHostValues;
  openPort443 = nginxEnabled && lib.length virtualHostWithSSL > 0;
in {
  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@00a.ch";
  };

  services.nginx = {
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  networking.firewall.allowedTCPPorts = (lib.optional openPort80 80) ++ (lib.optional openPort443 443);
}
