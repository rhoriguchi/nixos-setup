{
  colors,
  config,
  lib,
  pkgs,
  ...
}:
let
  disabledColor = colors.extra.terminal.border;
in
{
  # TODO HYPRLAND add to the right side power button which calls power menu
  # TODO HYPRLAND add custom icon module to show nightlight state and toggle it
  # TODO HYPRLAND icon theme not working

  programs.waybar = {
    enable = true;

    systemd.enable = true;

    # TODO HYPRLAND remove
    systemd.enableInspect = true;

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

        # TODO HYPRLAND move to center?
        "hyprland/submap"
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
        on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl -e4 -n2 set 3%+";
        on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl -e4 -n2 set 3%-";

        tooltip = false;
      };

      battery = {
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

        on-click = "${pkgs.writeShellScript "toggle-bluetooth.sh" ''
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
      };

      "custom/notification" = {
        # TODO HYPRLAND maybe add notification count?
        #  Alternatively, the number of notifications can be shown by adding `{}` anywhere in the `format` field in the Waybar config
        # format = "{} {icon}";
        format = "{icon}";
        format-icons = {
          notification = " <sup> </sup>";
          none = " ";
          dnd-notification = "<span color='${disabledColor}'> </span><sup> </sup>";
          dnd-none = "<span color='${disabledColor}'> </span>";
          inhibited-notification = " <sup> </sup>";
          inhibited-none = " ";
          dnd-inhibited-notification = "<span color='${disabledColor}'> </span<sup> </sup>";
          dnd-inhibited-none = "<span color='${disabledColor}'> </span";
        };
        return-type = "json";
        exec = "${config.services.swaync.package}/bin/swaync-client --subscribe-waybar";
        on-click = "${config.services.swaync.package}/bin/swaync-client --toggle-dnd";
        on-click-right = "${config.services.swaync.package}/bin/swaync-client --toggle-panel";
        # TODO HYPRLAND what does this do?
        escape = true;

        tooltip = false;
      };

      disk = {
        format = "󰋊 {percentage_used}%";
        path = "/";

        tooltip-format = "{specific_used:0.2f} GB / {specific_total:0.2f} GB";
        unit = "GB";
      };

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          # TODO HYPRLAND change color when active?
          activated = " ";
          deactivated = "<span color='${disabledColor}'> </span>";
        };

        tooltip = false;
      };

      memory = {
        interval = 1;

        format = "  {percentage}%";

        tooltip-format = "{used:0.1f} GB / {total:0.1f} GB";
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

        on-click = "${pkgs.writeShellScript "toggle-wifi.sh" ''
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

        on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

        scroll-step = 5;
        smooth-scrolling-threshold = 1;
        on-scroll-up = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
        on-scroll-down = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-";
      };

      # TODO HYPRLAND right click styling is unreadable
      # TODO HYPRLAND add css to align center
      tray = {
        icon-size = 22;
        spacing = 5;
      };

      # TODO HYPRLAND make red or accent background?
      # TODO HYPRLAND capitalize first letter or all?
      "hyprland/submap" = {
        format = "  {}";

        on-click = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch submap reset";

        tooltip = false;
      };

      "hyprland/workspaces" = {
        sort-by-number = true;

        on-click = "activate";
      };
    };

    style = ''
      * {
        font-family: ${config.gtk.font.name};
        font-size: 17px;
        color: ${colors.normal.white};
      }

      window#waybar {
        background-color: ${colors.normal.black};
        border-bottom: none;
      }

      /* TODO HYPRLAND https://github.com/Alexays/Waybar/issues/1399 */
      /* TODO HYPRLAND https://github.com/Alexays/Waybar/issues/1634 */
      /* TODO HYPRLAND does not work */
      window#waybar.hidden {
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
        padding: 0 5px;
        background-color: transparent;
      }

      #workspaces button:hover {
        /* TODO HYPRLAND use background color */
        background: rgba(0, 0, 0, 0.2);
      }

      /* TODO HYPRLAND does not work */
      #workspaces button.focused {
        background-color:rgb(21, 0, 255);
        box-shadow: inset 0 -3px ${colors.extra.terminal.border};
      }

      /* TODO HYPRLAND make it blink */
      #workspaces button.urgent {
        background-color: ${colors.normal.red};
      }

      /* TODO HYPRLAND Not sure what this does */
      #mode {
        background-color:rgb(0, 255, 47);
        border-bottom: 3px solid #ffffff;
      }

      ${
        let
          configuredModules =
            config.programs.waybar.settings.topBar.modules-left
            ++ config.programs.waybar.settings.topBar.modules-center
            ++ config.programs.waybar.settings.topBar.modules-right;
          modules = map (
            module: lib.replaceStrings [ "hyprland/" "/" "#" ] [ "" "-" "." ] module
          ) configuredModules;
        in
        lib.concatStringsSep ", " (map (module: "#${module}") modules)
      } {
        padding: 0 10px;
      }
    '';
  };
}
