{ secrets, ... }:
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

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [
        "derp-zrh.00a.ch"
      ];
    };

    nginx.virtualHosts."derp-zrh.00a.ch".enableACME = true;
  };
}
