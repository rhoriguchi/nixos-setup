{ lib, pkgs, config, secrets, ... }: {
  services = {
    prowlarr = {
      enable = true;
      openFirewall = true;
    };

    sonarr = {
      enable = true;
      openFirewall = true;

      group = if config.services.resilio.enable then "rslsync" else "sonarr";
    };

    deluge = {
      enable = true;
      openFirewall = true;

      web.enable = true;

      declarative = true;
      group = if config.services.resilio.enable then "rslsync" else "sonarr";

      authFile = let
        text = lib.concatStringsSep "\n"
          (lib.mapAttrsToList (key: value: "${key}:${value.password}:${toString value.level}") secrets.deluge.users);
      in pkgs.writeText "deluge-auth" text;

      config = {
        download_location = "/mnt/Data/Deluge/Downloads";

        copy_torrent_file = true;
        torrentfiles_location = "/mnt/Data/Deluge/Torrents";

        allow_remote = true;
        daemon_port = 58846;
        listen_ports = [ 6881 6889 ];

        stop_seed_at_ratio = true;
        stop_seed_ratio = 0.0;

        max_download_speed = 1000 * 80;
        max_upload_speed = 1000 * 10;

        max_active_downloading = 10;
        max_active_limit = 10;
        max_active_seeding = 1;
        max_connections_global = 250;
        max_half_open_connections = 40;
      };
    };

    # openvpn.servers.sonarrVPN = {
    #   config = "config ${./nl.protonvpn.net.udp.ovpn}";

    #   authUserPass = {
    #     username = "PJDW8BQLyl_loNHR1Q63lYwz";
    #     password = "ngoZQhs/R589ssqdcg/1i8Is";
    #   };
    # };
  };

  systemd.services.sonarr-update-tracked-series = {
    description = "Update tracked tv time series in Sonarr";

    after = [ "network.target" "sonarr.service" ];

    script = let
      pythonWithPackages = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.beautifulsoup4 pythonPackages.requests ]);

      script = pkgs.writeText "sonar_update_series.py"
        (lib.replaceStrings [ "SONAR_API_URL" "SONARR_API_KEY" "SONARR_ROOT_DIR" "TV_TIME_USERNAME" "TV_TIME_PASSWORD" ] [
          "http://127.0.0.1:8989"
          secrets.sonarr.apiKey
          "${config.services.resilio.syncPath}/Series/Tv Shows"
          secrets.tvTime.username
          secrets.tvTime.password
        ] (lib.readFile ./update_series.py));
    in "${pythonWithPackages}/bin/python ${script}";

    startAt = "*:0/15";

    serviceConfig = {
      DynamicUser = true;
      Restart = "on-abort";
    };
  };
}
