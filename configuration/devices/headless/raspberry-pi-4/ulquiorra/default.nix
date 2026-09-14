{
  config,
  wifis,
  ...
}:
let
  ssid = "63466727-IoT";
in
{
  imports = [
    ../common.nix

    ./print-server.nix
  ];

  sops = {
    secrets."wifis/${ssid}" = { };

    templates."networking.wireless.secretsFile" = {
      owner = "wpa_supplicant";

      content = "${ssid}=${config.sops.placeholder."wifis/${ssid}"}";

      restartUnits = [ config.systemd.services.wpa_supplicant.name ];
    };
  };

  time.timeZone = "Europe/Zurich";

  networking = {
    hostName = "XXLPitu-Ulquiorra";

    wireless = {
      enable = true;

      extraConfig = ''
        p2p_disabled=1
      '';

      networks.${ssid} = {
        # TODO Remove when raspberry pi supports WPA3 https://forums.raspberrypi.com/viewtopic.php?t=277468
        authProtocols = [ "WPA-PSK" ];
        extraConfig = wifis.mkExtraConfig ssid [ "WPA-PSK" ] { headless = true; };
        pskRaw = "ext:${ssid}";
      };

      secretsFile = config.sops.templates."networking.wireless.secretsFile".path;
    };

    firewall.allowedTCPPorts = [
      config.services.nginx.defaultHTTPListenPort
      config.services.nginx.defaultSSLListenPort
    ];
  };
}
