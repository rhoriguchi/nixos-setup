{ pkgs, utils, config, ... }: {
  home-manager.users.rhoriguchi.programs.gnome-terminal = {
    enable = true;

    showMenubar = true;

    profile = {
      "e17653c5-1b1f-418d-9833-ccb64992112d" = {
        default = true;

        allowBold = true;
        # audibleBell = false; # TODO commented because this a new feature https://github.com/nix-community/home-manager/pull/1671
        cursorBlinkMode = "on";
        visibleName = "DEFAULT";

        colors = {
          backgroundColor = "#303030";
          cursor = {
            background = "#B10DC9";
            foreground = "#FFFFFF";
          };
          foregroundColor = "#FFFFFF";
          highlight = {
            background = "#FFFFFF";
            foreground = "#B10DC9";
          };
          palette = [
            "#000000"
            "#FF4136"
            "#2ECC40"
            "#FFDC00"
            "#0074D9"
            "#B10DC9"
            "#7FDBFF"
            "#EAEAEA"
            "#777777"
            "#FF8D86"
            "#81E08C"
            "#FFEA66"
            "#66ABE8"
            "#D06DDE"
            "#B2E9FF"
            "#FFFFFF"
          ];
        };
      };
    };
  };
}
