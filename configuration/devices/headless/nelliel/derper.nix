{ secrets, ... }:
{
  services = {
    tailscale.derper = {
      enable = true;

      openFirewall = true;

      verifyClients = false;

      domain = "derp-nbg.00a.ch";
      configureNginx = true;
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [
        "derp-nbg.00a.ch"
      ];
    };

    nginx.virtualHosts."derp-nbg.00a.ch".enableACME = true;
  };
}
