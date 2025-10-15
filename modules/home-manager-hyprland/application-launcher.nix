{
  colors,
  config,
  lib,
  pkgs,
  ...
}:
let

in
{
  home.file.".cache/nwg-pin-cache".source = pkgs.writeText "nwg-pin-cache" "";

  wayland.windowManager.hyprland.settings.bind = [
    "$mainMod, R, exec, ${pkgs.nwg-drawer}/bin/nwg-drawer ${
      lib.concatStringsSep " " [
        "-closebtn right" # close button position: 'left' or 'right', 'none' by default (default "none")
        "-nocats" # Disable filtering by category
        "-nofs" # Disable file search
        "-s ${pkgs.writeText "drawer.css" ''
          window {
            background-color: ${colors.extra.terminal.background};
            color: ${colors.normal.white};
            font-family: ${config.gtk.font.name};
          }

          entry {
            border-color: ${colors.extra.terminal.border};
          }

          entry > image {
            color: ${colors.extra.terminal.border};
          }

          entry:focus {
            border-color: ${colors.normal.accent};
            color: ${colors.normal.white};
          }

          entry:focus > image {
            color: ${colors.normal.white};
          }

          entry selection {
            background-color: ${colors.normal.white};
            color: ${colors.extra.terminal.background};
          }

          button,
          image {
            background: none;
            border: none;
          }

          button:focus,
          button:hover {
            box-shadow: 0 0 0 1px ${colors.extra.terminal.border};
            border-radius: 4px;
            outline: none;
          }

          button:hover image {
            -gtk-icon-effect: none;
          }

          #close-button,
          #close-button:focus
          #close-button:hover {
            box-shadow: none
          }

          #math-label {
            font-weight: bold;
            font-size: 16px
          }
        ''}"
      ]
    }"
  ];
}
