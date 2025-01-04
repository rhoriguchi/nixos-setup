{ config, pkgs, secrets, ... }: {
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

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.tautulli.port}";
          basicAuth = secrets.nginx.basicAuth."tautulli.00a.ch";

          extraConfig = ''
            satisfy any;

            allow 192.168.1.0/24;
            deny all;
          '';
        };
      };
    };
  };

  systemd.services.tautulli = rec {
    path = [ pkgs.gnused ];

    preStart = ''
      sed -i '/http_password/d' '${config.services.tautulli.configFile}'
      sed -i '/http_username/d' '${config.services.tautulli.configFile}'
    '';
    preStop = preStart;
  };
}
