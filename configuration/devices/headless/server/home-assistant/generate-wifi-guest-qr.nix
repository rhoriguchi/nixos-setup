{ pkgs, config, secrets, ... }:
let
  ssid = "63466727-Guest";
  password = secrets.wifis.${ssid}.psk;

  script = pkgs.writers.writePython3 "generate_wifi_guest_qr.py" { libraries = [ pkgs.python3Packages.qrcode ]; } ''
    import sys

    import qrcode

    qr = qrcode.QRCode(error_correction=qrcode.constants.ERROR_CORRECT_Q)
    qr.add_data('WIFI:T:WPA;S:${ssid};P:${password};;')
    qr.make()

    img = qr.make_image(fill_color='#3498db')
    img.save(sys.argv[1])
  '';

  qrCode = pkgs.runCommand "wifi_guest_qr.png" { } "${script} $out";
in {
  systemd.tmpfiles.rules = [
    "d /run/hass/img 0700 ${config.services.nginx.user} ${config.services.nginx.group}"
    "L+ /run/hass/img/wifi-guest-qr.png - - - - ${qrCode}"
  ];
}
