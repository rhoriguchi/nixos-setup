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
      IdentityFile ${home}/.ssh/id_rsa
      NumberOfPasswordPrompts 3
      PubkeyAuthentication yes
      StrictHostKeyChecking ask
    '';

    matchBlocks = {
      "github.com" = {
        user = "git";
        identityFile = "${home}/.ssh/github_rsa";
      };

      "gitlab.com" = {
        user = "git";
        identityFile = "${home}/.ssh/gitlab_rsa";
      };

      "jcrk.synology.me" = {
        user = "xxlpitu";
        port = 10022;
      };
    } // (let
      ips = import ../default/wireguard-network/ips.nix;
      clientIps = lib.filterAttrs (key: _: key != "Ryan-Laptop") ips;
    in lib.mapAttrs' (key: value:
      lib.nameValuePair (lib.toLower key) {
        hostname = value;
        user = "xxlpitu";
        extraOptions.HostKeyAlias = lib.toLower key;
      }) clientIps);
  };
}
