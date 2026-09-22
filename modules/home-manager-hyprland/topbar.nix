{
  colors,
  config,
  lib,
  libCustom,
  pkgs,
  ...
}:
let
  disabledColor = colors.extra.terminal.border;
in
{
  programs.waybar = {
    enable = true;

    systemd.enable = true;

    settings.topBar = {
      layer = "top";
      position = "top";

      modules-left = [
        "clock"
        "backlight"
        "battery"
        "pulseaudio"
        "bluetooth"
        "network"
        "hyprland/submap"

        # Needed for `window#waybar.empty`
        "hyprland/window"
      ];
      modules-center = [ "hyprland/workspaces" ];
      modules-right = [
        "network#traffic"
        "cpu"
        "memory"
        "disk"
        "idle_inhibitor"
        "custom/notification"
        "tray"
        "custom/power"
      ];

      backlight = {
        interval = 1;

        format = "{icon} {percent}%";
        format-icons = [
          "󰛩 "
          "󱩎 "
          "󱩏 "
          "󱩐 "
          "󱩑 "
          "󱩒 "
          "󱩓 "
          "󱩔 "
          "󱩔 "
          "󱩖 "
          "󰛨 "
        ];

        scroll-step = 1;
        smooth-scrolling-threshold = 1;
        on-scroll-up = "${pkgs.wtype}/bin/wtype -k XF86MonBrightnessUp";
        on-scroll-down = "${pkgs.wtype}/bin/wtype -k XF86MonBrightnessDown";

        tooltip = false;
      };

      battery = {
        # TODO remove when version > 0.15.0
        bat = "BAT0";

        interval = 10;

        format = "{icon}{capacity}%";
        format-icons = [
          "󰁺 "
          "󰁻 "
          "󰁼 "
          "󰁽 "
          "󰁾 "
          "󰁿 "
          "󰂀 "
          "󰂁 "
          "󰂂 "
          "󰁹 "
        ];
        format-charging = "<span color='${colors.normal.green}'>󰂄 </span>{capacity}%";
        format-warning = "<span color='${colors.normal.yellow}'>{icon}</span>{capacity}%";
        format-critical = "<span color='${colors.normal.red}'>{icon}</span>{capacity}%";

        states = {
          warning = 25;
          critical = 15;
        };

        tooltip-format = "Remaining battery {time}";
        tooltip-format-charging = "Time till full {time}";
        tooltip-format-full = "";
      };

      bluetooth = {
        interval = 1;

        format-on = " ";
        format-connected = " ";
        format-off = "<span color='${disabledColor}'>󰂲 </span>";
        format-disabled = "<span color='${disabledColor}'>󰂲 </span>";

        on-click = "${pkgs.writers.writeBash "toggle-bluetooth.sh" ''
          state=$(${pkgs.bluez}/bin/bluetoothctl show | ${pkgs.gnugrep}/bin/grep "Powered:" | awk '{print $2}')
          case "$state" in
            yes)
              ${pkgs.bluez}/bin/bluetoothctl power off
              ;;
            no)
              ${pkgs.bluez}/bin/bluetoothctl power on
              ;;
          esac
        ''}";

        tooltip = false;
      };

      clock = {
        interval = 1;

        format = "{:%H:%M:%S}";
        tooltip-format = "{:%d.%m.%Y}";
      };

      cpu = {
        interval = 1;

        format = "  {usage}%";
        tooltip = false;
      };

      "custom/notification" = {
        format = "{icon}";
        format-icons = {
          notification = " <sup> </sup>";
          none = " ";
          dnd-notification = "<span color='${disabledColor}'> </span><sup> </sup>";
          dnd-none = "<span color='${disabledColor}'> </span>";
          inhibited-notification = " <sup> </sup>";
          inhibited-none = " ";
          dnd-inhibited-notification = "<span color='${disabledColor}'> </span><sup> </sup>";
          dnd-inhibited-none = "<span color='${disabledColor}'> </span>";
        };
        return-type = "json";
        exec = "${config.services.swaync.package}/bin/swaync-client --subscribe-waybar";
        on-click = "${config.services.swaync.package}/bin/swaync-client --toggle-dnd";
        on-click-right = "${config.services.swaync.package}/bin/swaync-client --toggle-panel";

        tooltip = false;
      };

      "custom/power" = {
        format = " ";
        on-click = "${pkgs.wtype}/bin/wtype -M logo -k Escape -m logo";

        tooltip = false;
      };

      disk = {
        format = "󰋊 {percentage_used}%";
        path = "/";

        tooltip = false;
        unit = "GB";
      };

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = " ";
          deactivated = "<span color='${disabledColor}'> </span>";
        };

        tooltip = false;
      };

      memory = {
        interval = 1;

        format = "  {percentage}%";

        tooltip = false;
      };

      network = {
        interval = 1;

        format-ethernet = "󰲚 {ifname}";
        format-wifi = "{icon} {essid}";
        format-icons = [
          "󰤯 "
          "󰤟 "
          "󰤢 "
          "󰤥 "
          "󰤨 "
        ];
        format-linked = "<span color='${disabledColor}'>󰤫 </span> {essid}";
        format-disconnected = "<span color='${disabledColor}'>󰤭 </span>";
        format-disabled = "<span color='${disabledColor}'>󰲜 </span>";

        tooltip-format-wifi = "{signaldBm} dBm ({signalStrength}%)";

        on-click = "${pkgs.writers.writeBash "toggle-wifi.sh" ''
          if [ $(${pkgs.networkmanager}/bin/nmcli radio wifi | ${pkgs.gawk}/bin/awk '/led/ {print}') = 'enabled'  ] ; then
            ${pkgs.networkmanager}/bin/nmcli radio wifi off
          else
            ${pkgs.networkmanager}/bin/nmcli radio wifi on
          fi
        ''}";
      };

      "network#traffic" = {
        interval = 1;

        format = " {bandwidthDownBytes}  {bandwidthUpBytes} ";
        tooltip-format = "{ifname} {ipaddr}/{cidr}";
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "<span color='${disabledColor}'> </span>";
        format-icons.default = [
          " "
          " "
          "  "
        ];
        format-bluetooth = " {volume}% {format_source}";
        format-bluetooth-muted = "<span color='${disabledColor}'> </span>";
        format-source = " {volume}%";
        format-source-muted = " ";

        tooltip = false;

        on-click = "${pkgs.wtype}/bin/wtype -k XF86AudioMute";

        scroll-step = 5;
        smooth-scrolling-threshold = 1;
        on-scroll-up = "${pkgs.wtype}/bin/wtype -k XF86AudioRaiseVolume";
        on-scroll-down = "${pkgs.wtype}/bin/wtype -k XF86AudioLowerVolume";
      };

      tray = {
        icon-size = 22;
        spacing = 3;
      };

      "hyprland/submap" = {
        format = "  {}";

        on-click = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch '${
          (libCustom.hyprland._mkLuaCommand {
            dispatcher = "submap";
            args = "reset";
          }).expr
        }'";

        tooltip = false;
      };

      "hyprland/window".format = "";

      "hyprland/workspaces" = {
        sort-by-number = true;

        on-click = "activate";
      };
    };

    style = ''
      * {
        font-family: ${config.gtk.font.name};
        font-size: 17px;
        font-feature-settings: "tnum";
        color: ${colors.normal.white};
      }

      window#waybar {
        background-color: ${colors.normal.black};
        border: none;
      }

      window#waybar.empty {
        background-color: transparent;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left > widget:first-child > #workspaces {
        margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right > widget:last-child > #workspaces {
        margin-right: 0;
      }

      button {
        /* Use box-shadow instead of border so the text isn't offset */
        box-shadow: inset 0 -3px transparent;
        /* Avoid rounded borders under each button name */
        border: none;
        border-radius: 0;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      button:hover {
        background: inherit;
        box-shadow: inset 0 -3px ${colors.extra.terminal.border};
      }

      #workspaces button {
        padding: 0 6px;
        margin: 4px 1px;
        border-radius: 4px;
        background-color: transparent;
        transition: background-color 0.15s ease-in-out;
      }

      #workspaces button:hover {
        background: rgba(255, 255, 255, 0.1);
        box-shadow: none;
      }

      #workspaces button.active {
        background-color: ${colors.normal.accent};
      }

      @keyframes urgent-blink {
        50% {
          background-color: transparent;
        }
      }

      #workspaces button.urgent {
        background-color: ${colors.normal.red};
        animation: urgent-blink 1s steps(2, end) infinite;
      }

      #submap {
        background-color: ${colors.normal.accent};
        color: ${colors.normal.white};
        margin: 4px 2px;
        border-radius: 4px;
      }

      #custom-notification {
        letter-spacing: -2px;
      }

      menu, tooltip {
        background-color: ${colors.extra.terminal.background};
        border: 1px solid ${colors.extra.terminal.border};
        padding: 5px;
      }

      menuitem label, tooltip label {
        color: ${colors.normal.white};
      }

      menuitem:hover {
        background-color: ${colors.normal.accent};
      }

      ${
        lib.pipe
          (
            config.programs.waybar.settings.topBar.modules-left
            ++ config.programs.waybar.settings.topBar.modules-center
            ++ config.programs.waybar.settings.topBar.modules-right
          )
          [
            (builtins.filter (module: module != "hyprland/window"))

            (map (module: lib.replaceStrings [ "hyprland/" "/" "#" ] [ "" "-" "." ] module))

            (map (module: "#${module}"))

            (lib.concatStringsSep ", ")
          ]
      } {
        padding: 0 6px;
      }
    '';
  };
}
