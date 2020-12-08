{ pkgs, config, ... }:
let dag = config.home-manager.users.rhoriguchi.lib.dag;
in {
  # TODO generate public keys and change permissions of .ssh

  home-manager.users.rhoriguchi.programs.ssh = {
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

      "*.duckdns.org" =
        dag.entryBefore [ "github.com" "gitlab.com" ] { user = "xxlpitu"; };
    };
  };
}
