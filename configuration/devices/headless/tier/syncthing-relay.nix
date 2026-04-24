{
  config,
  pkgs,
  secrets,
  ...
}:
{
  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "syncthing-relay.00a.ch" ];
    };

    # TODO scrape metrics https://github.com/syncthing/syncthing/issues/5116#issuecomment-947941441
    # > curl http://localhost:22070/status
    # TODO `services.prometheus.exporters.json` use nspawn container to have isolated json exporter?
    syncthing.relay = {
      enable = true;

      key = "${pkgs.writeText "key.pem" secrets.syncthing.relay.key}";
      cert = "${pkgs.writeText "cert.pem" secrets.syncthing.relay.cert}";

      extraOptions = [ "-token ${secrets.syncthing.relay.token}" ];

      providedBy = config.networking.hostName;
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.syncthing.relay.port ];
}
