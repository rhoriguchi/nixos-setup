{ pkgs, config, secrets, ... }: {
  imports = [ ./deluge ./prowlarr.nix ];

  services = {
    sonarr = {
      enable = true;

      group = if config.services.resilio.enable then "rslsync" else "sonarr";
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "sonarr.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."sonarr.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:8989";
          basicAuth = secrets.nginx.basicAuth."sonarr.00a.ch";
        };
      };
    };
  };

  systemd.services = {
    sonarr.serviceConfig.UMask = "0002";

    sonarr-update-tracked-series = {
      after = [ "network.target" "sonarr.service" ];

      script = let
        pythonWithPackages = pkgs.python3.withPackages (ps: [ ps.pyjwt ps.requests ]);

        script = pkgs.substituteAll {
          src = ./update_series.py;

          sonarApiUrl = "http://127.0.0.1:8989";
          sonarApiKey = secrets.sonarr.apiKey;
          sonarrRootDir = "${config.services.resilio.syncPath}/Series/Tv Shows";

          tvTimeUsername = secrets.tvTime.username;
          tvTimePassword = secrets.tvTime.password;
        };
      in "${pythonWithPackages}/bin/python ${script}";

      startAt = "*:0/15";

      serviceConfig = {
        DynamicUser = true;
        Restart = "on-abort";
      };
    };
  };
}
