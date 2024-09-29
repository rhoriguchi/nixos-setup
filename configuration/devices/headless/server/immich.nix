{ config, secrets, ... }: {
  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "immich.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."immich.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.immich.port}";
          proxyWebsockets = true;

          extraConfig = ''
            proxy_buffering off;

            client_max_body_size 50000M;
          '';
        };
      };
    };

    immich = {
      enable = true;

      host = "127.0.0.1";
      group = if config.services.resilio.enable then "rslsync" else "immich";
    };
  };

  # TODO remove when https://github.com/NixOS/nixpkgs/issues/344738 fixed
  users.groups.immich = { };
}
