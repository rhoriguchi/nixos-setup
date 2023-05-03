{ lib, pkgs, config, secrets, ... }:
let vpnInterface = "tun-deluge";
in {
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

          extraConfig = ''
            satisfy any;

            # TODO test if needed
            deny  192.168.1.1;
            allow 192.168.1.0/24;
            deny all;
          '';
        };
      };
    };

    # openvpn.servers.deluge = {
    #   config = let
    #     ips = [
    #       # Netherlands
    #       "138.199.7.129"
    #       "146.70.86.114"
    #       "185.107.56.224"
    #       "185.107.56.229"
    #       "185.107.57.49"
    #       "185.107.80.190"
    #       "190.2.131.156"
    #       "190.2.132.124"
    #       "190.2.132.139"
    #       "62.112.9.164"
    #     ];
    #     ports = [ 1194 4569 51820 5060 80 ];

    #     remotes = lib.flatten (map (ip: map (port: "remote ${ip} ${toString port}") ports) ips);
    #   in ''
    #     auth SHA512
    #     verb 3

    #     client
    #     dev ${vpnInterface}
    #     proto udp
    #     persist-tun

    #     pull
    #     route-nopull

    #     ${lib.concatStringsSep "\n" remotes}
    #     server-poll-timeout 20
    #     remote-random
    #     resolv-retry infinite
    #     nobind

    #     fast-io
    #     tun-mtu 1500
    #     tun-mtu-extra 32
    #     mssfix 1450
    #     reneg-sec 0

    #     persist-key
    #     ca ${./ca.pem}

    #     setenv CLIENT_CERT 0
    #     remote-cert-tls server
    #     tls-auth ${./server.key} 1
    #   '';

    #   authUserPass = {
    #     username = secrets.protonvpn.username;
    #     password = secrets.protonvpn.password;
    #   };
    # };

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

        outgoing_interface = vpnInterface;
      };
    };
  };
}

