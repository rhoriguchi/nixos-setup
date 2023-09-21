{ pkgs, config, lib, colors, ... }: {
  home = {
    packages = [ pkgs.nano ];

    activation.deleteGitconfig = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
      rm -f ${config.home.homeDirectory}/.gitconfig
    '';
  };

  programs.git = {
    enable = true;

    userName = "Ryan Horiguchi";
    userEmail = "ryan.horiguchi@gmail.com";

    extraConfig = {
      alias = {
        changes = "diff --stat";
        history = ''log --date=iso --pretty="%C(${colors.normal.yellow})%H  %C(bold ${colors.normal.blue})%ad %C(auto)%d %C(reset)%s"'';
        tracked = let
          colorize = color: text: "${color}${text}\\e[0m";

          # TODO figure out how to use hex colors variable
          red = colorize "\\x1b[1;38;5;203m";
          green = colorize "\\x1b[1;38;5;41m";
        in ''
          !f() { if [ $# -eq 0 ]; then echo -e '${
            red "Missing file or directory"
          }'; else tracked=$(git ls-files ''${1}); if [[ -z ''${tracked} ]]; then echo -e "${red "Not tracked"} ''${1}"; else echo -e "${
            green "Tracked"
          } ''${1}"; fi; fi; }; f'';
      };

      init.defaultBranch = "master";

      core = {
        editor = "nano";
        pager = "less --raw-control-chars --quit-if-one-screen --no-init";
        symlinks = true;
      };

      color.ui = true;

      "gitflow \"prefix\"" = {
        feature = "feature/";
        release = "release/";
        hotfix = "hotfix/";
        support = "support/";
      };

      # TODO remove when https://github.com/libgit2/libgit2/issues/6531 fixed
      index.skipHash = false;

      pull.ff = "only";

      push.default = "simple";

      feature.manyFiles = true;

      fetch.prune = true;

      tag.forceSignAnnotated = true;

      signing = {
        key = "5CC220FFA648E8A6C3D21D96CA7EE98D45A1132A";
        signByDefault = true;
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
