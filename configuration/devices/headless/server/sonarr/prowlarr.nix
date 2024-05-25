{ config, pkgs, secrets, ... }: {
  services = {
    prowlarr.enable = true;

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "prowlarr.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."prowlarr.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:9696";
          proxyWebsockets = true;
          basicAuth = secrets.nginx.basicAuth."prowlarr.00a.ch";

          recommendedProxySettings = false;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP 127.0.0.1;
            proxy_set_header X-Forwarded-For 127.0.0.1;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Server $host;

            satisfy any;

            allow 192.168.1.0/24;
            deny all;
          '';
        };
      };
    };
  };

  # https://hub.docker.com/r/flaresolverr/flaresolverr
  virtualisation.oci-containers.containers.flaresolverr = {
    image = "flaresolverr/flaresolverr:v3.3.19";

    imageFile = pkgs.dockerTools.pullImage {
      imageName = "flaresolverr/flaresolverr";
      imageDigest = "sha256:0bdf9ed48f3c54c998bc160be46244ce3a88a7783b6cfd31eec9c1667786152f"; # linux/amd64
      sha256 = "sha256-QrLd1Lb7HxZbPEUKy1eFvSuurb35NX3UvFab3E8M/RA=";

      finalImageTag = "v3.3.19";
    };

    ports = [ "8191:8191" ];

    environment.TZ = config.time.timeZone;
  };
}
