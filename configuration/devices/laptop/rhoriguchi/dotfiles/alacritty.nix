{ pkgs, utils, config, ... }:
# TODO hand this over as variable
let username = "rhoriguchi";
in {
  home-manager.users."${username}".programs.alacritty = {
    enable = true;

    settings = {
      shell.program =
        "${utils.toShellPath config.users.users."${username}".shell}";
      working_directory = config.users.users."${username}".home;
      window = "Maximized";

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      colors = {
        primary = {
          background = "#303030";
          foreground = "#FFFFFF";
        };

        cursor = {
          cursor = "#B10DC9";
          text = "#FFFFFF";
        };

        normal = {
          black = "#000000";
          red = "#FF4136";
          green = "#2ECC40";
          yellow = "#FFDC00";
          blue = "#0074D9";
          magenta = "#B10DC9";
          cyan = "#7FDBFF";
          white = "#eaeaea";
        };

        bright = {
          black = "#323232";
          red = "#FF8D86";
          green = "#81E08C";
          yellow = "#FFEA66";
          blue = "#66ABE8";
          magenta = "#D06DDE";
          cyan = "#B2E9FF";
          white = "#ffffff";
        };
      };
    };
  };
}
