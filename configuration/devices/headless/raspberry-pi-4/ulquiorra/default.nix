{ secrets, ... }: {
  imports = [
    ../common.nix

    ./print-server.nix
  ];

  networking = {
    hostName = "XXLPitu-Ulquiorra";

    wireless = {
      enable = true;

      extraConfig = ''
        p2p_disabled=1
      '';

      networks."63466727-IoT" = secrets.wifis."63466727-IoT" // {
        # TODO Remove when raspberry pi supports WPA3 https://forums.raspberrypi.com/viewtopic.php?t=277468
        authProtocols = [ "WPA-PSK" ];
      };
    };
  };

  services = {
    wireguard-network = {
      enable = true;
      type = "client";
      serverHostname = "XXLPitu-Server";
    };

    monitoring = {
      enable = true;

      type = "child";
      parentHostname = "XXLPitu-Server";
      apiKey = secrets.monitoring.apiKey;
    };
  };
}
