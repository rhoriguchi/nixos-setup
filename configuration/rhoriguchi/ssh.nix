{ config, ... }:
let home = config.users.users.rhoriguchi.home;
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
      "*.duckdns.org".user = "xxlpitu";

      "xxlpitu-pi-hole" = config.home-manager.users.rhoriguchi.lib.dag.entryAfter [ "*.duckdns.org" ] {
        user = "xxlpitu";
        proxyJump = "xxlpitu-server.duckdns.org";
      };

      "github.com" = {
        user = "git";
        identityFile = "${home}/.ssh/github_rsa";
      };

      "gitlab.com" = {
        user = "git";
        identityFile = "${home}/.ssh/gitlab_rsa";
      };

      "jcrk.synology.me".user = "jdh";
    };
  };
}
