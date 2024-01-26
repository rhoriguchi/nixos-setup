{ config, secrets, ... }: {
  imports = [ ./airgradient-one.nix ];

  services = {
    esphome = {
      enable = true;

      allowedDevices = [
        "/dev/serial/by-id/usb-Espressif_USB_JTAG_serial_debug_unit_84:FC:E6:02:59:C0-if00" # AirGradient ONE
      ];

      # TODO uncomment when merged https://nixpk.gs/pr-tracker.html?pr=284075
      # usePing = true;
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
        };
      };
    };
  };

  # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=284075
  systemd.services.esphome.environment.ESPHOME_DASHBOARD_USE_PING = "true";
}
