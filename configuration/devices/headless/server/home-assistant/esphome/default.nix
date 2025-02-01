{ config, secrets, ... }: {
  imports = [ ./airgradient-one.nix ];

  services = {
    esphome = {
      enable = true;

      allowedDevices = [
        "/dev/serial/by-id/usb-Espressif_USB_JTAG_serial_debug_unit_84:FC:E6:02:59:C0-if00" # AirGradient ONE
      ];
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "esphome.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."esphome.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.esphome.port}";
          proxyWebsockets = true;
          basicAuth = secrets.nginx.basicAuth."esphome.00a.ch";

          extraConfig = ''
            proxy_buffering off;

            satisfy any;

            allow 192.168.2.0/24;
            deny all;
          '';
        };
      };
    };
  };
}
