{
  config,
  ...
}:
let
  port = 9090;
in
{
  sops = {
    secrets."nginx+services/prometheus/pushPassword".key = "services/prometheus/pushPassword";

    templates."services.nginx.prometheus.htpasswd" = {
      content = "alloy:{PLAIN}${config.sops.placeholder."nginx+services/prometheus/pushPassword"}";

      owner = config.services.nginx.user;
      group = config.services.nginx.group;

      reloadUnits = [ config.systemd.services.nginx.name ];
    };
  };

  fileSystems."/mnt/Data/Monitoring/prometheus" = {
    depends = [ "/mnt/Data/Monitoring" ];
    device = "/var/lib/${config.services.prometheus.stateDir}";
    fsType = "none";
    options = [ "bind" ];
  };

  services = {
    prometheus = {
      enable = true;

      listenAddress = "127.0.0.1";
      port = 56712;

      extraFlags = [ "--web.enable-remote-write-receiver" ];

      retentionTime = "1y";
    };

    nginx = {
      enable = true;

      virtualHosts."prometheus" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = port;
          }
        ];

        basicAuthFile = config.sops.templates."services.nginx.prometheus.htpasswd".path;

        extraConfig = ''
          access_log off;
          client_max_body_size 16m;
        '';

        locations = {
          "= /api/v1/write".proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}";

          "/".return = 404;
        };
      };
    };
  };

  networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
    port
  ];
}
