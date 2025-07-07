rec {
  accentName = "magenta";

  extra = {
    terminal = {
      background = "#303030";
      border = "#9F9F9F";
    };

    tmux.statusBackground = "#3D3D3D";
  };

  normal = {
    accent = normal.${accentName};

    black = "#000000";
    blue = "#0074D9";
    cyan = "#7FDBFF";
    gray = "#C8C8C8";
    green = "#2ECC40";
    magenta = "#B10DC9";
    red = "#FF4136";
    white = "#FFFFFF";
    yellow = "#FFDC00";
  };

  bright = rec {
    accent = bright.${accentName};

    black = "#777777";
    blue = "#66ABE8";
    cyan = "#B2E9FF";
    gray = "#F3F3F3";
    green = "#81E08C";
    magenta = "#D06DDE";
    red = "#FF8D86";
    white = "#FFFFFF";
    yellow = "#FFEA66";
  };
}
