{
  config,
  lib,
  libCustom,
  ...
}:
{
  imports = [
    ./special-keys.nix
    ./submaps.nix
  ];

  wayland.windowManager.hyprland.settings.bind = [
    (libCustom.hyprland.mkExecBindRule {
      mods = "SUPER";
      key = "Q";
      command = "${config.programs.ghostty.package}/bin/ghostty";
    })
    (libCustom.hyprland.mkBindRule {
      mods = "SUPER";
      key = "C";
      dispatcher = "killActive";
    })
    (libCustom.hyprland.mkBindRule {
      mods = "ALT";
      key = "F4";
      dispatcher = "killActive";
    })
    (libCustom.hyprland.mkBindRule {
      mods = "SUPER";
      key = "V";
      dispatcher = "toggleFloating";
    })
    (libCustom.hyprland.mkBindRule {
      mods = "SUPER";
      key = "F";
      dispatcher = "toggleFullscreen";
    })
    (libCustom.hyprland.mkBindRule {
      mods = "SUPER";
      key = "P";
      dispatcher = "togglePseudo";
    })

    (libCustom.hyprland.mkBindRule {
      mods = "SUPER + SHIFT";
      key = "left";
      dispatcher = "moveWindow";
      args.direction = "left";
    })
    (libCustom.hyprland.mkBindRule {
      mods = "SUPER + SHIFT";
      key = "right";
      dispatcher = "moveWindow";
      args.direction = "right";
    })
    (libCustom.hyprland.mkBindRule {
      mods = "SUPER + SHIFT";
      key = "up";
      dispatcher = "moveWindow";
      args.direction = "up";
    })
    (libCustom.hyprland.mkBindRule {
      mods = "SUPER + SHIFT";
      key = "down";
      dispatcher = "moveWindow";
      args.direction = "down";
    })

    (libCustom.hyprland.mkBindRule {
      mods = "SUPER";
      key = "left";
      dispatcher = "moveFocus";
      args = "left";
    })
    (libCustom.hyprland.mkBindRule {
      mods = "SUPER";
      key = "right";
      dispatcher = "moveFocus";
      args = "right";
    })
    (libCustom.hyprland.mkBindRule {
      mods = "SUPER";
      key = "up";
      dispatcher = "moveFocus";
      args = "up";
    })
    (libCustom.hyprland.mkBindRule {
      mods = "SUPER";
      key = "down";
      dispatcher = "moveFocus";
      args = "down";
    })

    (libCustom.hyprland.mkBindRule {
      mods = "SUPER";
      key = "mouse_down";
      dispatcher = "switchWorkspace";
      args = "e+1";
    })
    (libCustom.hyprland.mkBindRule {
      mods = "SUPER";
      key = "mouse_up";
      dispatcher = "switchWorkspace";
      args = "e-1";
    })
  ]
  ++ lib.pipe (lib.genList (x: x + 1) 10) [
    (map (number: [
      (libCustom.hyprland.mkBindRule {
        mods = "SUPER";
        key = if number == 10 then 0 else number;
        dispatcher = "switchWorkspace";
        args = number;
      })
      (libCustom.hyprland.mkBindRule {
        mods = "SUPER + SHIFT";
        key = if number == 10 then 0 else number;
        dispatcher = "moveToWorkspace";
        args = number;
      })
    ]))

    lib.flatten
  ];
}
