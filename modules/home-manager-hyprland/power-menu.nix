# TODO HYPRLAND find something better
# https://github.com/ArtsyMacaw/wlogout
{
  colors,
  config,
  libCustom,
  osConfig,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland.settings.bind = [
    (libCustom.hyprland.mkExecBindRule {
      mods = "SUPER";
      key = "ESCAPE";
      command = "${pkgs.nwg-bar}/bin/nwg-bar";
    })
  ];

  xdg.configFile = {
    "nwg-bar/bar.json".source = pkgs.writers.writeJSON "bar.json" [
      {
        label = "Suspend";
        exec = "${osConfig.systemd.package}/bin/systemctl suspend";
        icon = "${pkgs.nwg-bar}/share/nwg-bar/images/system-suspend.svg";
      }
      {
        label = "Shutdown";
        exec = "${osConfig.systemd.package}/bin/systemctl poweroff";
        icon = "${pkgs.nwg-bar}/share/nwg-bar/images/system-shutdown.svg";
      }
      {
        label = "Reboot";
        exec = "${osConfig.systemd.package}/bin/systemctl reboot";
        icon = "${pkgs.nwg-bar}/share/nwg-bar/images/system-reboot.svg";
      }
    ];

    "nwg-bar/style.css".source = pkgs.writeText "style.css" ''
      * {
        color: ${colors.normal.white};
        font-family: "${config.gtk.font.name}";
        font-size: ${toString config.gtk.font.size}pt;
      }

      window {
        background-color: ${colors.normal.black}
      }

      #outer-box {
        margin: 0px
      }

      #inner-box {
        background-color: alpha(${colors.normal.black}, 0.85);
        border-radius: 10px;
        border-style: none;
        padding: 5px;
        margin: 5px
      }

      button, image {
        background: none;
        border: none;
        box-shadow: none
      }

      button {
        padding-left: 10px;
        padding-right: 10px;
        margin: 5px
      }

      button:hover {
        background-color: ${colors.normal.accent}
      }
    '';
  };
}
