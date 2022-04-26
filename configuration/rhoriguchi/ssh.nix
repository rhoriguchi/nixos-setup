{ config, ... }:
let
  home = config.users.users.rhoriguchi.home;

  dag = config.home-manager.users.rhoriguchi.lib.dag;

  wireguardIps = (import ../modules/wireguard-vpn/ips.nix);
in {
  home-manager.users.rhoriguchi.programs.ssh = {
    enable = true;

    compression = true;
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

      jdh-server = {
        hostname = wireguardIps.JDH-Server;
        user = "xxlpitu";

        proxyJump = "wireguard.00a.ch";
      };

      xxlpitu-adguard = {
        hostname = wireguardIps.XXLPitu-AdGuard;
        user = "xxlpitu";

        proxyJump = "wireguard.00a.ch";
      };

      xxlpitu-horgen = {
        hostname = wireguardIps.XXLPitu-Horgen;
        user = "xxlpitu";

        proxyJump = "wireguard.00a.ch";
      };
    };
  };
}
