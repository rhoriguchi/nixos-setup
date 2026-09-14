{ ... }:
{
  services = {
    tailscale.derper = {
      enable = true;

      openFirewall = true;

      verifyClients = false;

      domain = "derp-zrh.00a.ch";
      configureNginx = true;
    };

    infomaniak = {
      enable = true;

      hostnames = [
        "derp-zrh.00a.ch"
      ];
    };

    nginx.virtualHosts."derp-zrh.00a.ch" = {
      enableACME = true;
      acmeRoot = null;
    };
  };
}
