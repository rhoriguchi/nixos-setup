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
          '';
        };
      };
    };
  };

  # https://hub.docker.com/r/flaresolverr/flaresolverr
  virtualisation.oci-containers.containers.flaresolverr = {
    image = "flaresolverr/flaresolverr:v3.3.15";

    imageFile = pkgs.dockerTools.pullImage {
      imageName = "flaresolverr/flaresolverr";
      imageDigest = "sha256:c79f8d736b1a22e969ab29c11dbfbd8cc62cc7fcad09e1fd0bff93a710a7c59e"; # linux/amd64
      sha256 = "sha256-DA7TSVMM/Lh5W3ix1NJLKmk4oh32ttLt3DvKEoHQ9dM=";

      finalImageTag = "v3.3.15";
    };

    ports = [ "8191:8191" ];

    environment.TZ = config.time.timeZone;
  };
}
