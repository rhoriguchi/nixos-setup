{ pkgs, ... }: {
  home-manager.users.rhoriguchi.programs.git = {
    enable = true;

    userName = "Ryan Horiguchi";
    userEmail = "ryan.horiguchi@gmail.com";

    extraConfig = {
      alias = {
        changes = "diff --stat";
        history = ''log --date=relative --pretty=format:"%C(yellow)%H  %C(blue)%>(14)%ad %C(auto)%d %C(reset)%s"'';
      };

      init.defaultBranch = "master";

      core.symlinks = true;

      "gitflow \"prefix\"" = {
        feature = "feature/";
        release = "release/";
        hotfix = "hotfix/";
        support = "support/";
      };

      pull.ff = "only";

      push.default = "simple";

      feature.manyFiles = true;

      tag.forceSignAnnotated = true;

      signing = {
        key = "5CC220FFA648E8A6C3D21D96CA7EE98D45A1132A";
        signByDefault = true;
        gpgPath = "${pkgs.gnupg}/bin/gpg2";
      };
    };

    ignores = [
      # Allway Sync
      "_SYNCAPP"

      # Mac files
      ".DS_Store"
      "[Dd]esktop.ini"
      "._*"
      "[Tt]humbs.db"

      # Windows files
      "[Dd]esktop.ini"
      "Thumbs.db"
      "Thumbs.db:encryptable"
      "ehthumbs.db"
      "ehthumbs_vista.db"

      # Files on external disks
      ".Spotlight-V100"
      ".Trashes"

      # Microsoft office
      "*.tmp"
      "~$*.doc*"
      "~$*.xls*"
      "*.xlk"
      "~$*.ppt*"
      "*.~vsd*"
    ];
  };
}
