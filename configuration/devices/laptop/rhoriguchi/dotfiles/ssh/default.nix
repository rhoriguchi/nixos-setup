{ config, ... }:
# TODO hand this over as variable
let userName = "rhoriguchi";
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
      "gitlab.com" = {
        identityFile = "${./keys/gitlab_rsa}";
        user = "git";
      };

      "*.duckdns.org" =
        config.home-manager.users."${userName}".lib.dag.entryBefore [ "gitlab.com" ] { user = "xxlpitu"; };
    };
  };
}
