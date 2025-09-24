{ config, secrets, ... }:
{
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

    firewall.allowedTCPPorts = [
      config.services.nginx.defaultHTTPListenPort
      config.services.nginx.defaultSSLListenPort
    ];
  };
}
