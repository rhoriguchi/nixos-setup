{ config, lib, ... }:
let home = config.home.homeDirectory;
in {
  programs.ssh = {
    enable = true;

    compression = true;
    controlMaster = "auto";
    controlPath = "${home}/.ssh/master-%r@%n:%p";
    hashKnownHosts = false;
    serverAliveCountMax = 3;
    serverAliveInterval = 10;
    userKnownHostsFile = "${home}/.ssh/known_hosts";

    extraConfig = ''
      AddKeysToAgent yes
      ConnectionAttempts 3
      IdentityFile ${home}/.ssh/id_rsa
      NumberOfPasswordPrompts 3
      PubkeyAuthentication yes
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

      "*.00a.ch".user = "xxlpitu";
    } // (let
      # TODO get this somehow through "nixosModules.default" so no relative path needs to be imported
      ips = import ../default/wireguard-network/ips.nix;
      clientIps = lib.filterAttrs (key: _: key != "server") ips;
    in lib.mapAttrs' (key: value:
      lib.nameValuePair (lib.toLower key) {
        hostname = value;
        user = "xxlpitu";

        proxyJump = "wireguard.00a.ch";
      }) clientIps);
  };
}
