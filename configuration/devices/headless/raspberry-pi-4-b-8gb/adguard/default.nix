{ config, ... }: {
  imports = [ ../../default.nix ../default.nix ./hardware-configuration.nix ];

  networking.hostName = "XXLPitu-AdGuard";

  services = {
    nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."${config.networking.hostName}" = {
        forceSSL = true;
        listen = [{ port = 3000; }];
        locations."/".proxyPass = "http://localhost:3000";
        basicAuth.admin = (import ../../../../secrets.nix).services.adguard.password;
      };
    };

    # TODO create initial config yaml and than create with nix
    adguardhome.enable = true;
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 3000 ];
    allowedUDPPorts = [ 53 ];
  };
}
