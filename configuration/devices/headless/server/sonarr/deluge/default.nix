{ lib, pkgs, config, secrets, ... }: {
  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "deluge.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."deluge.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.deluge.web.port}";
          basicAuth = secrets.nginx.basicAuth."deluge.00a.ch";
        };
      };
    };

    deluge = {
      enable = true;

      package = pkgs.deluge.overrideAttrs (_: { patches = [ ./remove-web-login.patch ]; });

      openFirewall = true;

      web.enable = true;

      declarative = true;
      group = if config.services.resilio.enable then "rslsync" else "sonarr";

      authFile = let
        text = lib.concatStringsSep "\n"
          (lib.mapAttrsToList (key: value: "${key}:${value.password}:${toString value.level}") secrets.deluge.users);
      in pkgs.writeText "deluge-auth" text;

      config = rec {
        download_location = "/mnt/Data/Deluge/Downloads";

        copy_torrent_file = true;
        torrentfiles_location = "/mnt/Data/Deluge/Torrents";

        allow_remote = true;
        daemon_port = 58846;
        listen_ports = [ 6881 6889 ];

        stop_seed_at_ratio = true;
        stop_seed_ratio = 0.0;

        max_download_speed = builtins.floor (100 * 1000 * 0.8);
        max_upload_speed = builtins.floor (20 * 1000 * 0.8);

        max_active_downloading = 10;
        max_active_seeding = 10;
        max_active_limit = max_active_downloading + max_active_seeding;
        dont_count_slow_torrents = true;

        max_connections_global = 250;
        max_half_open_connections = 40;
      };
    };
  };
}

