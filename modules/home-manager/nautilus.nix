{ config, lib, ... }:
let homeDirectory = config.home.homeDirectory;
in {
  # TODO commented since this causes issues on darwin
  # programs.zsh.shellAliases.open = "${pkgs.nautilus}/bin/nautilus";
  programs.zsh.shellAliases.open = "nautilus";

  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file://${homeDirectory}/Downloads/Browser Downloads
    file://${homeDirectory}/Sync
    file://${homeDirectory}/Sync/Git Sync/Git
    file://${homeDirectory}/Sync/Series Sync/Series

    ${let
      wireguardIps = import ../default/wireguard-network/ips.nix;
      filteredWireguardIps = lib.filterAttrs (key: _: key != "Ryan-Laptop") wireguardIps;
    in lib.concatStringsSep "\n" (map (hostname: "sftp://root@${hostname} ${hostname}") (lib.attrNames filteredWireguardIps))}
  '';

  #
}
