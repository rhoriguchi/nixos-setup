{ pkgs, ... }: {
  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "firefox-syncserver.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."firefox-syncserver.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.firefox-syncserver.settings.port}";
          basicAuth = secrets.nginx.basicAuth."firefox-syncserver.00a.ch";

          extraConfig = ''
            satisfy any;

            allow 192.168.1.0/24;
            deny all;
          '';
        };
      };
    };

    mysql.package = pkgs.mariadb;

    firefox-syncserver = {
      enable = true;

      secrets = pkgs.writeText "firefox-syncserver-secrets" ''
        SYNC_MASTER_SECRET=this-secret-is-actually-leaked-to-/nix/store
      '';

      singleNode = rec {
        enable = true;

        hostname = "firefox-syncserver.00a.ch";
        url = "http://${hostname}";
      };
    };
  };
}
