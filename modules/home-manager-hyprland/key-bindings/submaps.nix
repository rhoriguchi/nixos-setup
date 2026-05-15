{ libCustom, ... }:
{
  wayland.windowManager.hyprland = {
    settings.bind = [
      (libCustom.hyprland.mkBindRule {
        mods = "SUPER";
        key = "M";
        dispatcher = "submap";
        args = "Move";
        flags.release = true;
      })
      (libCustom.hyprland.mkBindRule {
        mods = "SUPER";
        key = "N";
        dispatcher = "submap";
        args = "Resize";
        flags.release = true;
      })
    ];

    submaps = {
      Move.settings = {
        bind = [
          (libCustom.hyprland.mkBindRule {
            key = "escape";
            dispatcher = "submap";
            args = "reset";
            flags.release = true;
          })

          (libCustom.hyprland.mkBindRule {
            key = "left";
            dispatcher = "moveWindow";
            args = {
              x = -10;
              y = 0;
              relative = true;
            };
            flags.repeating = true;
          })
          (libCustom.hyprland.mkBindRule {
            key = "right";
            dispatcher = "moveWindow";
            args = {
              x = 10;
              y = 0;
              relative = true;
            };
            flags.repeating = true;
          })
          (libCustom.hyprland.mkBindRule {
            key = "up";
            dispatcher = "moveWindow";
            args = {
              x = 0;
              y = -10;
              relative = true;
            };
            flags.repeating = true;
          })
          (libCustom.hyprland.mkBindRule {
            key = "down";
            dispatcher = "moveWindow";
            args = {
              x = 0;
              y = 10;
              relative = true;
            };
            flags.repeating = true;
          })
        ];
      };

      Resize.settings = {
        bind = [
          (libCustom.hyprland.mkBindRule {
            key = "escape";
            dispatcher = "submap";
            args = "reset";
            flags.release = true;
          })

          (libCustom.hyprland.mkBindRule {
            key = "left";
            dispatcher = "resizeWindow";
            args = {
              x = -10;
              y = 0;
              relative = true;
            };
            flags.repeating = true;
          })
          (libCustom.hyprland.mkBindRule {
            key = "right";
            dispatcher = "resizeWindow";
            args = {
              x = 10;
              y = 0;
              relative = true;
            };
            flags.repeating = true;
          })
          (libCustom.hyprland.mkBindRule {
            key = "up";
            dispatcher = "resizeWindow";
            args = {
              x = 0;
              y = -10;
              relative = true;
            };
            flags.repeating = true;
          })
          (libCustom.hyprland.mkBindRule {
            key = "down";
            dispatcher = "resizeWindow";
            args = {
              x = 0;
              y = 10;
              relative = true;
            };
            flags.repeating = true;
          })
        ];
      };
    };
  };
}
