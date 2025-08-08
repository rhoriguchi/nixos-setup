{ colors, config, pkgs, ... }: {
  home.packages = [ pkgs.nerd-fonts.roboto-mono ];

  programs.wofi = {
    enable = true;

    settings = {
      prompt = "";

      width = 600;
      height = 400;
      location = "center";

      show = "drun";
      matching = "fuzzy";
      no_actions = true;
      insensitive = true;
      allow_images = true;
      hide_scroll = true;
    };

    # TODO HYPRLAND remove top and bottom line when scrolling
    # man wofi(5)
    style = ''
      window {
        margin: 5px;
        border-radius: 8px;
        /* TODO figure out how to use hex colors variable `colors.normal.black` */
        background-color: rgba(0, 0, 0, 0.9);
        font-family: RobotoMono Nerd Font;
      }

      #outer-box {
        margin: 0;
        padding: 5px;
        background-color: transparent;
      }

      #input {
        margin: 8px;
        padding: 10px 12px;
        border: 2px solid ${colors.extra.terminal.border};
        border-radius: 8px;
        color: ${colors.normal.white};
        background-color: ${colors.extra.terminal.background};
        outline: none;
        caret-color: ${colors.normal.accent};
        font-size: 14px;
      }

      #input:focus {
        border-color: ${colors.normal.accent};
        box-shadow: none;
      }

      /* magnifying glass */
      #input > image.left {
        color: ${colors.extra.terminal.border};
      }

      /* delete icon */
      #input > image.right {
        color: ${colors.extra.terminal.border};
      }

      #scroll {
        margin: 0;
        padding: 5px;
      }

      #inner-box {
        margin: 8px;
        padding-top: 5px;
        background-color: transparent;
      }

      #entry {
        padding: 8px;
        margin: 2px 5px;
        transition: all 0.2s ease;
        box-shadow: none;
      }

      /* TODO HYPRLAND does not work when moved with arrow keys */
      #entry:selected {
        border: 2px solid ${colors.normal.accent};
        border-radius: 8px;
        box-shadow: none;
        background-color: ${colors.extra.terminal.background};
      }

      #img {
        margin-right: 10px;
        margin-left: 5px;
        background: none;
      }

      #text {
        margin: 3px;
        padding: 3px;
        color: ${colors.normal.white};
        font-size: 13px;
      }

      #text:selected {
        color: ${colors.normal.accent};
        font-weight: bold;
      }
    '';
  };

  wayland.windowManager.hyprland.settings.bind = [ "$mainMod, R, exec, ${config.programs.wofi.package}/bin/wofi" ];
}
