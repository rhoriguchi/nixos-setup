{ config, ... }:
let home = config.users.users.rhoriguchi.home;
in {
  home-manager.users.rhoriguchi.programs.ssh = {
    enable = true;

    compression = true;
    hashKnownHosts = false;
    serverAliveCountMax = 3;
    serverAliveInterval = 10;

    extraConfig = ''
      AddKeysToAgent yes
      ConnectionAttempts 3
      IdentityFile ${home}/.ssh/id_rsa
      NumberOfPasswordPrompts 3
      PubkeyAuthentication yes
    '';

    matchBlocks = {
      "*.duckdns.org".user = "xxlpitu";

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
