{
  config,
  secrets,
  ...
}:
{
  fileSystems."/mnt/Data/Monitoring/prometheus" = {
    depends = [ "/mnt/Data/Monitoring" ];
    device = "/var/lib/${config.services.prometheus.stateDir}";
    fsType = "none";
    options = [ "bind" ];
  };

  services = {
    nginx = {
      enable = true;

      virtualHosts."prometheus.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        extraConfig = ''
          include /run/nginx-authelia/location.conf;
        '';

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}";

          extraConfig = ''
            include /run/nginx-authelia/auth.conf;

            satisfy any;
            allow 192.168.2.0/24;
            deny all;
          '';
        };
      };
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [
        "prometheus.00a.ch"
      ];
    };

    prometheus = {
      enable = true;

      extraFlags = [ "--web.enable-remote-write-receiver" ];
    };
  };

  networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
    config.services.prometheus.port
  ];
}
