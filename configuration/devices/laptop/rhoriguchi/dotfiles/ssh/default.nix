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

    # TODO generate new key and add to GitHub
    matchBlocks = {
      "gitlab.com" = {
        identityFile = "${./keys/gitlab_rsa}";
        user = "git";
      };

      "*.duckdns.org" = dag.entryBefore [ "gitlab.com" ] { user = "xxlpitu"; };
    };
  };
}
