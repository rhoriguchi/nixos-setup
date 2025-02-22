{ secrets, ... }: {
  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "rustdesk.00a.ch" ];
    };

    rustdesk-server = {
      enable = true;

      signal = {
        relayHosts = [ "rustdesk.00a.ch" ];
        extraArgs = [ "--key" "_" "--mask" "192.168.0.0/16" ];
      };

      relay.extraArgs = [ "--key" "_" ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 21115 21116 21117 21118 21119 ];

    allowedUDPPorts = [ 21116 ];
  };
}
