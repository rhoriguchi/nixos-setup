{
  config,
  lib,
  osConfig,
  ...
}:
let
  homeDirectory = config.home.homeDirectory;

  tailscaleIps = import (
    lib.custom.relativeToRoot "configuration/devices/headless/router/headscale/ips.nix"
  );
  filteredTailscaleIps = lib.filterAttrs (
    key: _:
    !(lib.elem key [
      osConfig.networking.hostName
      "headplane-agent"
    ])
  ) tailscaleIps;
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
    ++ map (hostname: "sftp://root@${hostname}/ ${hostname}") (lib.attrNames filteredTailscaleIps);
  };
}
