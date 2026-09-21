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
    XXLPitu-Aizen = "363RS66-HHFOZJU-WELSVBA-QA3F65E-TT4RWRA-ZL5GQLD-SGYDY3P-GWSY3QA";
    XXLPitu-Kenpachi = "YYM3EFW-N6FIAPX-XW5KVS3-YNESUJM-N7LGRYR-JJMSCAB-2ZFCXCL-UALT6QF";
    XXLPitu-Tier = "M3D4A27-MUVYIEK-ARPPZLQ-ZQVONPM-RB3VPKS-AGCWRV2-7VD2X2N-CXQW7QE";
  };
in
{
  sops.secrets = {
    "services/syncthing/webUI/password" = {
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

    webUI.passwordFile = config.sops.secrets."services/syncthing/webUI/password".path;

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
