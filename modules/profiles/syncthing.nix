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

    relay = {
      inherit (secrets.syncthing.relay) id token;
    };

    devices = lib.mapAttrs (key: value: {
      inherit (value) id;
      trusted = lib.elem key trustedDevices;
    }) (lib.filterAttrs (key: _: key != config.networking.hostName) secrets.syncthing.devices);

    folders = [
      "Books"
      "Documents"
      "Git"
      "KeePass"
      "Obsidian"
      "Series"
      "Signal"
      "Storage"
    ];
  };
}
