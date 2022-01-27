{ config, ... }:
let
  home = config.users.users.rhoriguchi.home;

  dag = config.home-manager.users.rhoriguchi.lib.dag;
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

      "*.duckdns.org".user = "xxlpitu";

      "xxlpitu-horgen.duckdns.org" = dag.entryBefore [ "*.duckdns.org" ] { port = 1234; };

      "xxlpitu-adguard" = {
        # TODO get hostname from "configuration/devices/headless/raspberry-pi-4-b-8gb/adguard/default.nix"
        hostname = "XXLPitu-AdGuard.local";
        user = "xxlpitu";
        proxyJump = "xxlpitu-home.duckdns.org";
      };

      "jcrk.synology.me".user = "xxlpitu";
    };
  };
}
