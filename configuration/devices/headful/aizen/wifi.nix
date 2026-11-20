{
  config,
  lib,
  wifis,
  ...
}:
{
  sops = {
    secrets = lib.listToAttrs (map (ssid: lib.nameValuePair "wifis/${ssid}" { }) wifis.passwordSsids);

    templates."networking.wireless.secretsFile" = {
      owner = "wpa_supplicant";

      content = lib.concatStrings (
        map (ssid: "${ssid}=${config.sops.placeholder."wifis/${ssid}"}\n") wifis.passwordSsids
      );

      restartUnits = [ config.systemd.services.wpa_supplicant.name ];
    };
  };

  networking = {
    networkmanager.unmanaged = [ "wlp0s20f3" ];

    wireless = {
      enable = true;

      userControlled = true;
      extraConfig = ''
        p2p_disabled=1
      '';

      networks = lib.recursiveUpdate wifis.wirelessNetworks {
        "63466727".priority = 100;
        "Hueco Mundo".priority = 10;
      };

      secretsFile = config.sops.templates."networking.wireless.secretsFile".path;
    };
  };
}
