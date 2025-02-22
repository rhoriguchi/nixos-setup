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

      relayIP = "rustdesk.00a.ch";
      extraSignalArgs = [ "--key" "_" "--mask" "192.168.0.0/16" ];
      extraRelayArgs = [ "--key" "_" ];
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ 21116 ];

    allowedTCPPorts = [ 21115 21116 21117 ];
  };
}
