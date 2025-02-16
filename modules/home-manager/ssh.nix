{ config, lib, ... }:
let home = config.home.homeDirectory;
in {
  programs.ssh = {
    enable = true;

    compression = true;
    controlPath = "${home}/.ssh/master-%r@%n:%p";
    hashKnownHosts = false;
    addKeysToAgent = "yes";
    serverAliveCountMax = 3;
    serverAliveInterval = 10;
    userKnownHostsFile = "${home}/.ssh/known_hosts";

    extraConfig = ''
      ConnectionAttempts 3
      IdentityFile ${home}/.ssh/id_ed25519
      NumberOfPasswordPrompts 3
      PubkeyAuthentication yes
      StrictHostKeyChecking ask
    '';

    matchBlocks = {
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
      filteredWireguardIps = lib.filterAttrs (key: _: key != "Ryan-Laptop") wireguardIps;
    in lib.mapAttrs' (key: value:
      lib.nameValuePair (lib.toLower key) {
        hostname = value;
        user = "xxlpitu";
        extraOptions.HostKeyAlias = lib.toLower key;
      }) filteredWireguardIps);
  };
}
