{ pkgs, config, colors, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })

    pkgs.roboto
  ];

  # TODO add to the right side power button which calls power menu

  # TODO add notification indicator https://github.com/ErikReider/SwayNotificationCenter#waybar-example and replace dunst with swaync
  #  package is called "swaynotificationcenter"

  # TODO show spotify current playing song and add media buttons - add to "modules-left"

  # TODO gtk icon theme not working, probably missing variable

  programs.waybar = {
    enable = true;

    systemd = {
      enable = true;

      target = "hyprland-session.target";
    };

    settings.topBar = {
      layer = "top";
      position = "top";

      modules-left = [ "wlr/workspaces" ];
      modules-center = [ "clock" "custom/notification" ];
      modules-right = [
        "cpu"
        "memory"
        "network"
        "tray"
        "idle_inhibitor" # TODO configure
        "pulseaudio"
        "backlight"
        "battery"
      ];

      backlight = rec {
        interval = 1;

        format = "{icon} {percent}%";
        format-icons = [ "󰛩" "󱩎" "󱩏" "󱩐" "󱩑" "󱩒" "󱩓" "󱩔" "󱩔" "󱩖" "󰛨" ];

        tooltip = false;

        scroll-step = 1;
        smooth-scrolling-threshold = 1;
        on-scroll-up = "${pkgs.light}/bin/light -A ${toString scroll-step}";
        on-scroll-down = "${pkgs.light}/bin/light -U ${toString scroll-step}";
      };

      battery = {
        format = "{icon} {capacity}%";
        format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        format-charging = "󰂄 {capacity}%";

        states = {
          warning = 30;
          critical = 15;
        };
        format-warning = ''<span color="${colors.normal.yellow}">{icon}</span> {capacity}%'';
        format-critical = ''<span color="${colors.normal.red}">{icon}</span> {capacity}%'';

        tooltip-format = "Remaining battery {time}";
        tooltip-format-charging = "Time till full {time}";
        tooltip-format-full = "";
      };

      clock = {
        format = "{:%d.%m.%Y %H:%M}";

        tooltip = false;
      };

      cpu = {
        interval = 1;

        # TODO spacing, probably use for every icon span with padding - icon wrapper function?
        format = " {icon}";
        format-icons = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
      };

      "custom/notification" = let inherit (config.services.swaync) package;
      in {
        tooltip = false;
        # TODO maybe add notification count?
        #  Alternatively, the number of notifications can be shown by adding `{}` anywhere in the `format` field in the Waybar config
        # format = "{} {icon}";
        format = "{icon}";
        format-icons = {
          notification = "<span color='${colors.normal.accent}'><sup></sup></span>";
          none = "";
          dnd-notification = "<span color='${colors.normal.accent}'><sup></sup></span>";
          dnd-none = "";
          inhibited-notification = "<span color='${colors.normal.accent}'><sup></sup></span>";
          inhibited-none = "";
          dnd-inhibited-notification = "<span color='${colors.normal.accent}'><sup></sup></span>";
          dnd-inhibited-none = "";
        };
        return-type = "json";
        exec = "${package}/bin/swaync-client -swb";
        on-click = "${package}/bin/swaync-client -t -sw";
        on-click-right = "${package}/bin/swaync-client -d -sw";
        escape = true;
      };

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "󰛊";
          deactivated = "󰾫";
        };

        tooltip = false;
      };

      memory = {
        interval = 1;

        format = "󰍛 {percentage}%";

        tooltip-format = "{used:0.1f} GB / {total:0.1f} GB";
      };

      network = {
        interval = 1;

        format-ethernet = "󰈀";
        format-wifi = "{icon}";
        # TODO get this to work
        # format-wifi = ''
        #   <span style="display: flex; align-items: center;">
        #     {icon}
        #     <span style="display: flex; flex-direction: column; padding-left: 5px;">
        #       <span>↓ {bandwidthDownBytes}</span>
        #       <span>↑ {bandwidthUpBytes}</span>
        #     </span>
        #   </span>
        # '';
        format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
        format-linked = "󰤫";
        format-disconnected = "";

        tooltip-format-ethernet = "{ifname}";
        tooltip-format-wifi = "{essid} ({signalStrength}%)";
        tooltip-format-linked = "{essid}";

        # TODO only open once
        on-click = "${pkgs.wpa_supplicant_gui}/bin/wpa_gui";
      };

      pulseaudio = rec {
        format = "{icon} {volume}%";
        format-muted = "󰖁";
        format-bluetooth = " {volume}% {format_source}";
        format-bluetooth-muted = " Mute";
        format-source = " {volume}%";
        format-source-muted = "";
        format-icons = rec {
          default = [ "" "" "" ];
          car = "";
          hdmi = "󰡁";
          headset = "󰋎";
          hifi = default;
          phone = "";
          portable = phone;
          speaker = "󰓃";
        };

        tooltip = false;

        on-click = "${pkgs.pamixer}/bin/pamixer --toggle-mute";
        on-click-middle = "${pkgs.pavucontrol}/bin/pavucontrol";

        scroll-step = 5;
        smooth-scrolling-threshold = 1;
        on-scroll-up = "${pkgs.pamixer}/bin/pamixer --increase ${toString scroll-step}";
        on-scroll-down = "${pkgs.pamixer}/bin/pamixer --decrease ${toString scroll-step}";
      };

      tray.spacing = 5;

      "wlr/workspaces" = {
        sort-by-number = true;

        on-click = "activate";
      };
    };

    # style = ''
    #   * {
    #     font-family: RobotoMono Nerd Font, Symbols Nerd Font Mono;
    #     font-size: 13px;
    #   }

    #   window#waybar {
    #     background-color: #303030;
    #     opacity: 0.79;
    #     transition-property: background-color;
    #     transition-duration: .5s;
    #   }

    #   #clock {
    #     font-size: 15px;
    #   }

    #   /* TODO does not work */
    #   #workspaces button.active {
    #     color: ${colors.normal.accent};
    #   }

    #   #workspaces button.urgent {
    #     color: ${colors.normal.red};
    #     /* TODO tweak */
    #     animation: blinker 1s linear infinite;
    #   }

    #   @keyframes blinker {
    #     50% {
    #       opacity: 0;
    #     }
    #   }
    # '';
  };
}
