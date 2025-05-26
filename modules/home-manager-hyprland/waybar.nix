{ colors, config, lib, pkgs, ... }:
let
  # TODO HYPRLAND CHANGE
  disabledColor = colors.extra.terminal.border;
in {
  home.packages = [ pkgs.nerd-fonts.roboto-mono ];

  # TODO HYPRLAND add to the right side power button which calls power menu
  # TODO HYPRLAND icon theme not working

  programs.waybar = {
    enable = true;

    systemd.enable = true;

    # TODO HYPRLAND remove
    systemd.enableInspect = true;

    settings.topBar = {
      layer = "top";
      position = "top";

      modules-left = [ "clock" "backlight" "battery" "network" "bluetooth" "pulseaudio" ];
      modules-center = [ "hyprland/workspaces" ];
      modules-right = [
        # TODO HYPRLAND add network traffic
        "disk"
        "cpu"
        "memory"
        "idle_inhibitor"
        # TODO HYPRLAND add custom icon module to show nightlight state and toggle it
        "custom/notification"
        "tray"
      ];

      backlight = rec {
        interval = 1;

        format = "{icon}{percent}%";
        format-icons = [ "󰛩 " "󱩎 " "󱩏 " "󱩐 " "󱩑 " "󱩒 " "󱩓 " "󱩔 " "󱩔 " "󱩖 " "󰛨 " ];

        scroll-step = 1;
        smooth-scrolling-threshold = 1;
        on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl -e4 -n2 set 3%+";
        on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl -e4 -n2 set 3%-";

        tooltip = false;
      };

      battery = {
        interval = 10;

        format = "{icon}{capacity}%";
        format-icons = [ "󰁺 " "󰁻 " "󰁼 " "󰁽 " "󰁾 " "󰁿 " "󰂀 " "󰂁 " "󰂂 " "󰁹 " ];
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
          state=$(${pkgs.bluez}/bin/bluetoothctl show | grep "Powered:" | awk '{print $2}')
          case "$state" in
            yes)
              ${pkgs.bluez}/bin/bluetoothctl power off
              ;;
            no)
              ${pkgs.bluez}/bin/bluetoothctl power on
              ;;
          esac
        ''}";
        # TODO HYPRLAND only open once same like screenshot
        on-click-right = "${pkgs.blueman}/bin/blueman-manager";

        tooltip = false;
      };

      clock = {
        interval = 1;

        format = "{:%H:%M:%S}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        # TODO HYPRLAND configure
        calendar = {
          mode = "year";
          mode-mon-col = 3;
          weeks-pos = "right";
          on-scroll = 1;
          format = {
            months = "<span color='#ffead3'><b>{}</b></span>";
            days = "<span color='#ecc6d9'><b>{}</b></span>";
            weeks = "";
            weekdays = "<span color='#ffcc66'><b>{}</b></span>";
            today = "<span color='#ff6699'><b><u>{}</u></b></span>";
          };
        };
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

        # TODO HYPRLAND only open once same like screenshot
        on-click-right = "${pkgs.gnome-disk-utility}/bin/gnome-disks";

        tooltip-format = "{specific_used:0.2f} GB / {specific_total:0.2f} GB";
        unit = "GB";
      };

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          # TODO HYPRLAND icon suck? maybe change color when active?
          activated = "󰛊 ";
          deactivated = "<span color='${disabledColor}'>󰾫 </span>";

          # TODO HYPRLAND maybe?
          # activated = " ";
          # deactivated = "<span color='${disabledColor}'> </span>";
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

        format-ethernet = " ";
        format-wifi = "{icon}";
        format-icons = [ "󰤯 " "󰤟 " "󰤢 " "󰤥 " "󰤨 " ];
        format-linked = "<span color='${disabledColor}'>󰤫 </span>";
        format-disconnected = "<span color='${disabledColor}'>󰤭 </span>";

        tooltip-format-ethernet = "{ifname}";
        tooltip-format-wifi = "{essid} ({signalStrength}%)";
        tooltip-format-linked = "{essid}";

        # TODO HYPRLAND only open once same like screenshot
        on-click-right = "${pkgs.wpa_supplicant_gui}/bin/wpa_gui";
      };

      pulseaudio = rec {
        format = "{icon}{volume}%";
        format-muted = "<span color='${disabledColor}'> </span>";
        format-icons.default = [ " " " " " " ];
        format-bluetooth = " {volume}% {format_source}";
        format-bluetooth-muted = "<span color='${disabledColor}'> </span>";
        format-source = " {volume}%";
        format-source-muted = " ";

        tooltip = false;

        on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";

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

      "hyprland/workspaces" = {
        sort-by-number = true;

        on-click = "activate";
      };
    };

    style = ''
      * {
        font-family: RobotoMono Nerd Font;
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
        lib.concatStringsSep ", " [
          "#backlight"
          "#battery"
          "#bluetooth"
          "#clock"
          "#cpu"
          "#disk"
          "#idle_inhibitor"
          "#memory"
          "#network"
          "#pulseaudio"
          "#tray"
        ]
      } {
        padding: 0 10px;
      }
    '';
  };
}
