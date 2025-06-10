{ config, secrets, ... }: {
  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "syncthing.00a.ch" ];
    };

    syncthing.relay = {
      enable = true;

      providedBy = config.networking.hostName;
      pools = [ "" ];
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.syncthing.relay.port ];
}
