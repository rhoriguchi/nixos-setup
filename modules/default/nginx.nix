{ lib, config, ... }:
let
  cfg = config.services.nginx;

  virtualHostValues = lib.attrValues config.services.nginx.virtualHosts;

  virtualHostsWithAcme = lib.filter (virtualHost: virtualHost.enableACME) virtualHostValues;
  openPort80 = lib.length virtualHostsWithAcme > 0;

  virtualHostWithSSL =
    lib.filter (virtualHost: virtualHost.addSSL || virtualHost.enableSSL || virtualHost.forceSSL || virtualHost.onlySSL) virtualHostValues;
  openPort443 = lib.length virtualHostWithSSL > 0;
in {
  config = lib.mkIf cfg.enable { networking.firewall.allowedTCPPorts = (lib.optional openPort80 80) ++ (lib.optional openPort443 443); };
}
