{ pkgs, secrets, ... }:
let
  ssid = secrets.services.home-assistant.config.wifi-guest.ssid;
  password = secrets.services.home-assistant.config.wifi-guest.password;

  script = pkgs.writeText "generate_wifi_guest_qr.py" ''
    import sys

    import qrcode

    qr = qrcode.QRCode(error_correction=qrcode.constants.ERROR_CORRECT_Q)
    qr.add_data('WIFI:T:WPA;S:${ssid};P:${password};;')
    qr.make()

    img = qr.make_image(fill_color='#3498db')
    img.save(sys.argv[1])
  '';

  pythonWithPackages = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.qrcode ]);

  qrCode = pkgs.runCommand "wifi_guest_qr" { } ''${pythonWithPackages}/bin/python ${script} "$out"'';
in { systemd.tmpfiles.rules = [ "L+ /run/hass/img/wifi-guest-qr.png - - - - ${qrCode}" ]; }
