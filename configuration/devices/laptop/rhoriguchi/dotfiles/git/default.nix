{ pkgs, ... }:
# TODO hand this over as variable
let userName = "rhoriguchi";
in {
  home-manager.users."${userName}".programs.git = {
    enable = true;

    userName = "Ryan Horiguchi";
    userEmail = "ryan.horiguchi@gmail.com";

    extraConfig = {
      init.defaultBranch = "master";

      core = {
        excludesfile = "${./gitignore}";
        symlinks = true;
      };

      "gitflow \"prefix\"" = {
        feature = "feature/";
        release = "release/";
        hotfix = "hotfix/";
        support = "support/";
      };

      push.default = "simple";

      feature.manyFiles = true;

      tag.forceSignAnnotated = true;

      signing = {
        # TODO add gpg key to nix config https://makandracards.com/makandra-orga/37763-gpg-extract-private-key-and-import-on-different-machine
        key = "5CC220FFA648E8A6C3D21D96CA7EE98D45A1132A";
        signByDefault = true;
        gpgPath = "${pkgs.gnupg}/bin/gpg2";
      };
    };
  };
}
