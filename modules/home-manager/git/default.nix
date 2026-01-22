{
  colors,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./template.nix ];

  home.activation.deleteGitconfig = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    rm -f '${config.home.homeDirectory}/.gitconfig'
  '';

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Ryan Horiguchi";
        email = "ryan.horiguchi@gmail.com";
      };

      alias = {
        alias = "! git config --get-regexp '^alias.' | sort | ${pkgs.gnused}/bin/sed -e 's/^alias\\.//' -e 's/\\ /\\ =\\ /'";

        changes = "! git diff --stat";
        graph = "! git history --graph --all --decorate";
        history = "! git log --pretty='%C(${colors.normal.yellow})%H  %C(bold ${colors.normal.blue})%ar %C(auto)%d %C(reset)%s'";
        last = "! git history -1";
        own-history = ''! git history --all --decorate --author="$(git config user.name)"'';
        tracked =
          let
            colorize = color: text: ''${color}${text}\e[0m'';

            # TODO figure out how to use hex colors variable
            red = colorize ''\x1b[1;38;5;203m'';
            green = colorize ''\x1b[1;38;5;41m'';
          in
          ''! f() { if [ $# -eq 0 ]; then echo -e '${red "Missing file or directory"}'; else tracked=$(git ls-files ''${1}); if [[ -z ''${tracked} ]]; then echo -e "${red "Not tracked"} ''${1}"; else echo -e "${green "Tracked"} ''${1}"; fi; fi; }; f'';
      };

      # TODO remove when https://github.com/libgit2/libgit2/issues/6531 fixed
      index.skipHash = false;

      init.defaultBranch = "master";

      pull.ff = "only";

      feature.manyFiles = true;

      fetch.prune = true;
    };

    signing = {
      format = "openpgp";
      key = "5CC220FFA648E8A6C3D21D96CA7EE98D45A1132A";
      signByDefault = true;
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
