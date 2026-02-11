{
  config,
  pkgs,
  secrets,
  ...
}:
{
  services = {
    tautulli.enable = true;

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "tautulli.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."tautulli.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        extraConfig = ''
          include /run/nginx-authelia/location.conf;
        '';

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.tautulli.port}";

          extraConfig = ''
            include /run/nginx-authelia/auth.conf;
          '';
        };
      };
    };
  };

  systemd.services.tautulli = rec {
    preStart = ''
      ${pkgs.gnused}/bin/sed -i '/http_password/d' '${config.services.tautulli.configFile}'
      ${pkgs.gnused}/bin/sed -i '/http_username/d' '${config.services.tautulli.configFile}'
    '';
    preStop = preStart;
  };
}
