{
  config,
  lib,
  libCustom,
  osConfig,
  ...
}:
let
  homeDirectory = config.home.homeDirectory;

  tailscaleIps = import (
    libCustom.relativeToRoot "configuration/devices/headless/nelliel/headscale/ips.nix"
  );
in
{
  gtk = {
    enable = true;

    gtk3.bookmarks = [
      "file://${homeDirectory}/Downloads/Browser Downloads"
      "file://${homeDirectory}/Pictures/Screenshots"
      "file://${homeDirectory}/Sync"
      "file://${homeDirectory}/Sync/Git Sync/Git"
      "file://${homeDirectory}/Sync/Series Sync/Series"
    ]
    ++ lib.pipe tailscaleIps [
      lib.attrNames

      (
        hostnames:
        lib.subtractLists [
          osConfig.networking.hostName
          "headplane-agent"
          "XXLPitu-Nnoitra"
        ] hostnames
      )

      (map (hostname: "sftp://root@${hostname}/ ${lib.replaceStrings [ "XXLPitu-" ] [ "" ] hostname}"))
    ];
  };
}
