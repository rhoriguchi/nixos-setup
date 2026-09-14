{
  config,
  pkgs,
  ...
}:
let
  ssid = "63466727-Guest";

  generateQr =
    pkgs.writers.writePython3 "generate_wifi_guest_qr.py"
      {
        libraries =
          let
            inherit (pkgs.python3Packages) qrcode;
          in
          [ qrcode ] ++ qrcode.optional-dependencies.all;
      }
      ''
        import os
        import sys

        import qrcode

        password = os.environ["WIFI_GUEST_PASSWORD"]

        qr = qrcode.QRCode(error_correction=qrcode.constants.ERROR_CORRECT_Q)
        qr.add_data(f'WIFI:T:WPA;S:${ssid};P:{password};;')
        qr.make()

        img = qr.make_image(fill_color='#3498db')
        img.save(sys.argv[1])
      '';
in
{
  sops.secrets."wifis/${ssid}" = {
    restartUnits = [ config.systemd.services.generate-wifi-guest-qr.name ];
  };

  systemd = {
    tmpfiles.rules = [
      "d /run/nginx-hass/img 0550 ${config.services.nginx.user} ${config.services.nginx.group}"
    ];

    services.generate-wifi-guest-qr = {
      wantedBy = [ "multi-user.target" ];
      after = [ "nginx.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        rm -f /run/nginx-hass/img/wifi-guest-qr.png

        WIFI_GUEST_PASSWORD="$(cat ${
          config.sops.secrets."wifis/${ssid}".path
        })" ${generateQr} /run/nginx-hass/img/wifi-guest-qr.png
        chown ${config.services.nginx.user}:${config.services.nginx.group} /run/nginx-hass/img/wifi-guest-qr.png
      '';
    };
  };
}
