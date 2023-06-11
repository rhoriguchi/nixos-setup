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

  virtualisation.oci-containers.containers.flaresolverr = {
    image = "flaresolverr/flaresolverr:v3.2.1";

    imageFile = pkgs.dockerTools.pullImage {
      imageName = "flaresolverr/flaresolverr";
      imageDigest = "sha256:648960c5a4118a085594aea0faf8d44bc08650c030c62805571c2ff2e4533982";
      sha256 = "sha256-esAQkugOUEnpNwMLNU6pVzB47ERBGcHVuKn4P1fd7nI=";

      finalImageTag = "v3.2.1";
    };

    ports = [ "8191:8191" ];

    environment.TZ = config.time.timeZone;
  };
}
