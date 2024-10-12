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
            proxy_buffering off;

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
    image = "flaresolverr/flaresolverr:v3.3.21";

    imageFile = pkgs.dockerTools.pullImage {
      imageName = "flaresolverr/flaresolverr";
      imageDigest = "sha256:f104ee51e5124d83cf3be9b37480649355d223f7d8f9e453d0d5ef06c6e3b31b"; # linux/amd64
      sha256 = "sha256-unGzkgDG5RvVPz+cHdNqizBjEf9FCHSMwi7PbRgjETI=";

      finalImageTag = "v3.3.21";
    };

    ports = [ "127.0.0.1:8191:8191" ];

    environment.TZ = config.time.timeZone;
  };
}
