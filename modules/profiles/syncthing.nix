{
  config,
  lib,
  ...
}:
let
  trustedDevices = [
    "XXLPitu-Aizen"
    "XXLPitu-Tier"
  ];

  deviceIds = {
    XXLPitu-Aizen = "J4MHKE6-7CAIMX4-W6KIDWA-AN65CJP-V5QRBW6-ZCCQYPI-DUCLNCG-5DUMYQR";
    XXLPitu-Kenpachi = "NDQ7FF6-NKUY6CN-HK3HGGA-MIOIRXM-F73WPGA-MDWSPE5-2OV5J3W-RVS6ZQG";
    XXLPitu-Tier = "TPIJZX2-NOLDQEN-UQ6WP7G-AJ5S2OT-E5MHDVJ-MLIGXGC-VNKK5AE-TMCMSQ2";
  };
in
{
  sops.secrets = {
    "services/syncthing/webUi/password" = {
      owner = config.services.custom-syncthing.user;
      group = config.services.custom-syncthing.group;

      restartUnits = [ config.systemd.services.syncthing-init.name ];
    };

    "services/syncthing/encryptionPassword" = {
      owner = config.services.custom-syncthing.user;
      group = config.services.custom-syncthing.group;

      restartUnits = [ config.systemd.services.syncthing-init.name ];
    };

    "services/syncthing/devices/${config.networking.hostName}/key" = {
      owner = config.services.custom-syncthing.user;
      group = config.services.custom-syncthing.group;

      restartUnits = [ config.systemd.services.syncthing.name ];
    };

    "services/syncthing/devices/${config.networking.hostName}/cert" = {
      owner = config.services.custom-syncthing.user;
      group = config.services.custom-syncthing.group;

      restartUnits = [ config.systemd.services.syncthing.name ];
    };
  };

  services.custom-syncthing = {
    enable = true;

    trusted = lib.elem config.networking.hostName trustedDevices;
    encryptionPasswordFile = config.sops.secrets."services/syncthing/encryptionPassword".path;

    key = config.sops.secrets."services/syncthing/devices/${config.networking.hostName}/key".path;
    cert = config.sops.secrets."services/syncthing/devices/${config.networking.hostName}/cert".path;

    webUI.passwordFile = config.sops.secrets."services/syncthing/webUi/password".path;

    devices = lib.pipe deviceIds [
      (lib.filterAttrs (key: _: key != config.networking.hostName))

      (lib.mapAttrs (
        key: id: {
          inherit id;
          trusted = lib.elem key trustedDevices;
        }
      ))
    ];

    folders = [
      "Documents"
      "Git"
      "Series"
      "Storage"
    ];
  };
}
