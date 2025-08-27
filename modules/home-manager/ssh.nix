{ config, lib, osConfig, ... }:
let home = config.home.homeDirectory;
in {
  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        identityFile = "${home}/.ssh/id_ed25519";

        compression = true;
        controlPath = "${home}/.ssh/master-%r@%n:%p";
        addKeysToAgent = "yes";
        serverAliveInterval = 10;
        userKnownHostsFile = "${home}/.ssh/known_hosts";

        extraOptions.ConnectionAttempts = "3";
      };

      "github.com" = {
        user = "git";
        identityFile = "${home}/.ssh/github_ed25519";
      };

      "gitlab.com" = {
        user = "git";
        identityFile = "${home}/.ssh/gitlab_ed25519";
      };

      "jcrk.synology.me" = {
        user = "xxlpitu";
        port = 10022;
      };
    } // (let
      wireguardIps = import (lib.custom.relativeToRoot "modules/default/wireguard-network/ips.nix");
      filteredWireguardIps = lib.filterAttrs (key: _: key != osConfig.networking.hostName) wireguardIps;
    in lib.mapAttrs' (key: value:
      lib.nameValuePair (lib.toLower key) {
        hostname = value;
        user = "xxlpitu";
        extraOptions.HostKeyAlias = lib.toLower key;
      }) filteredWireguardIps);
  };
}
