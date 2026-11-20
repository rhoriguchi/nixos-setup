{ config, ... }:
let
  hostName = "pykvm.00a.ch";
in
{
  # PiKVM V3 HAT: HDMI capture over CSI (TC358743) and the USB-C port in device mode for HID
  hardware.raspberry-pi.config.all.dt-overlays = {
    tc358743 = {
      enable = true;
      params = { };
    };

    dwc2 = {
      enable = true;
      params.dr_mode = {
        enable = true;
        value = "peripheral";
      };
    };
  };

  # Remote control of the attached host, only reachable over ethernet (the proxy on XXLPitu-Urahara forwards the
  # requests from the internet)
  networking.firewall.interfaces.eth0 = {
    allowedTCPPorts = [
      config.services.nginx.defaultHTTPListenPort
      config.services.nginx.defaultSSLListenPort
    ];

    allowedUDPPortRanges = [ config.services.pykvmd.webrtcPortRange ];
  };

  services = {
    pykvmd = {
      enable = true;

      variant = "v3-hdmi-rpi4";

      inherit hostName;

      # authelia is the only login, see the virtual host
      auth.enable = false;
    };

    infomaniak = {
      enable = true;

      hostnames = [ hostName ];
    };

    nginx.virtualHosts.${hostName} = {
      enableACME = true;
      forceSSL = true;

      # kvmd accepts every request without its own login, so everything on this host has to be behind authelia
      extraConfig = ''
        include /run/nginx-authelia/location.conf;
        include /run/nginx-authelia/auth.conf;
      '';
    };
  };
}
