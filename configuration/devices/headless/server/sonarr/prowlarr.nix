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
    image = "flaresolverr/flaresolverr:v3.3.17";

    imageFile = pkgs.dockerTools.pullImage {
      imageName = "flaresolverr/flaresolverr";
      imageDigest = "sha256:5f5661db1e69a6f80ac24d47d9fa5580f6f741ee5ec967818396ae0dacecd7ea"; # linux/amd64
      sha256 = "sha256-M175GXIUlCSCGwSbpkuuTpzwnCpQi3xn8A8ex0KuqWI=";

      finalImageTag = "v3.3.17";
    };

    ports = [ "8191:8191" ];

    environment.TZ = config.time.timeZone;
  };
}
