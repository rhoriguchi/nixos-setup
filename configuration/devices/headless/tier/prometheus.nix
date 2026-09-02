{
  config,
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
    prometheus = {
      enable = true;

      extraFlags = [ "--web.enable-remote-write-receiver" ];

      retentionTime = "1y";
    };
  };

  networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
    config.services.prometheus.port
  ];
}
