{ config, ... }:
let
  # TODO hand this over as variable
  userName = "rhoriguchi";

  dag = config.home-manager.users."${userName}".lib.dag;
in {
  home-manager.users."${userName}".programs.ssh = {
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
