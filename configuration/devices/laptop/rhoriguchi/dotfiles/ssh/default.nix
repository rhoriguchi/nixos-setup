{ config, ... }:
let
  # TODO hand this over as variable
  username = "rhoriguchi";

  dag = config.home-manager.users."${username}".lib.dag;
in {
  home-manager.users."${username}".programs.ssh = {
    enable = true;

    compression = true;
    hashKnownHosts = false;

    extraConfig = ''
      ConnectionAttempts 3
      IdentityFile ${./keys/id_rsa}
    '';

    matchBlocks = {
      "github.com" = {
        identityFile = "${./keys/github_rsa}";
        user = "git";
      };

      "gitlab.com" = {
        identityFile = "${./keys/gitlab_rsa}";
        user = "git";
      };

      "*.duckdns.org" = dag.entryBefore [ "github.com" "gitlab.com" ] { user = "xxlpitu"; };
    };
  };
}
