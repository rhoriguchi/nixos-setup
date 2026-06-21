{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  trustedDevices = [
    "XXLPitu-Aizen"
    "XXLPitu-Tier"
  ];
in
{
  services.custom-syncthing = {
    enable = true;

    trusted = lib.elem config.networking.hostName trustedDevices;
    encryptionPassword = secrets.syncthing.encryptionPassword;

    key = "${pkgs.writeText "key.pem" secrets.syncthing.devices.${config.networking.hostName}.key}";
    cert = "${pkgs.writeText "cert.pem" secrets.syncthing.devices.${config.networking.hostName}.cert}";

    webUI.password = secrets.syncthing.webUI.password;

    relay = {
      url = "syncthing-relay.00a.ch";
      inherit (secrets.syncthing.relay) id token;
    };

    devices = lib.pipe secrets.syncthing.devices [
      (lib.filterAttrs (key: _: key != config.networking.hostName))

      (lib.mapAttrs (
        key: value: {
          inherit (value) id;
          trusted = lib.elem key trustedDevices;
        }
      ))
    ];

    folders = [
      "Documents"
      "Git"
      "Obsidian"
      "Series"
      "Storage"
    ];
  };
}
