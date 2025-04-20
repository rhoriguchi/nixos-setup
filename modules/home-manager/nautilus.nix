{ config, lib, ... }:
let
  homeDirectory = config.home.homeDirectory;

  wireguardIps = import (lib.custom.relativeToRoot "modules/default/wireguard-network/ips.nix");
  filteredWireguardIps = lib.filterAttrs (key: _: key != "Ryan-Laptop") wireguardIps;
in {
  gtk = {
    enable = true;

    gtk3.bookmarks = [
      "file://${homeDirectory}/Downloads/Browser Downloads"
      "file://${homeDirectory}/Sync"
      "file://${homeDirectory}/Sync/Git Sync/Git"
      "file://${homeDirectory}/Sync/Series Sync/Series"
    ] ++ map (hostname: "sftp://root@${hostname}/ ${hostname}") (lib.attrNames filteredWireguardIps);
  };
}
