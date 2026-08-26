{
  colors,
  config,
  pkgs,
  ...
}:
let
  script = pkgs.writers.writeBash "system-checks" ''
    for battery in /sys/class/power_supply/BAT*; do
      [ -d "$battery" ] || continue

      capacity=$(${pkgs.coreutils}/bin/cat "$battery/capacity")
      status=$(${pkgs.coreutils}/bin/cat "$battery/status")

      if [ "$status" = "Discharging" ] && [ "$capacity" -lt 15 ]; then
        ${pkgs.libnotify}/bin/notify-send \
          --app-name="Battery" \
          --icon=dialog-warning \
          --urgency=critical \
          --replace-id=19420001 \
          "Low battery" "$capacity% remaining"
      fi

      break
    done

    read -r disk_blocks disk_free < <(${pkgs.coreutils}/bin/stat --file-system --format='%b %f' /)
    disk_percent=$(( (disk_blocks - disk_free) * 100 / disk_blocks ))

    if [ "$disk_percent" -ge 90 ]; then
      ${pkgs.libnotify}/bin/notify-send \
        --app-name="Disk Space" \
        --icon=dialog-warning \
        --urgency=critical \
        --replace-id=19420002 \
        "Low disk space" "/ is $disk_percent% full"
    fi
  '';
in
{
  services.swaync = {
    enable = true;

    # https://github.com/ErikReider/SwayNotificationCenter/blob/main/src/configSchema.json
    settings = {
      notification-inline-replies = true;
      notification-icon-size = 48;
      notification-body-image-height = 160;
      notification-body-image-width = 200;
      notification-window-width = 400;

      control-center-margin-top = config.wayland.windowManager.hyprland.settings.config.general.gaps_out;
      control-center-margin-bottom =
        config.wayland.windowManager.hyprland.settings.config.general.gaps_out;
      control-center-margin-right =
        config.wayland.windowManager.hyprland.settings.config.general.gaps_out;
      control-center-margin-left = config.wayland.windowManager.hyprland.settings.config.general.gaps_out;
      control-center-width = 400;

      widgets = [
        "mpris"
        "title"
        "notifications"
      ];

      widget-config.mpris.autohide = true;
    };

    style = ''
      * {
        color: ${colors.normal.white};
        font-family: ${config.gtk.font.name};
      }

      .control-center {
        background-color: ${colors.extra.terminal.background};
        border: ${toString config.wayland.windowManager.hyprland.settings.config.general.border_size}px solid ${colors.normal.accent};
        padding: 10px;
      }

      .widget-title {
        font-size: 16px;
        font-weight: bold;
        padding-bottom: 10px;
      }

      .widget-title > button {
        font-size: 1rem;
        background: ${colors.extra.terminal.border};
        box-shadow: none;
      }

      .widget-title > button:hover {
        background: ${colors.normal.red};
      }

      .notification-row {
        margin-top: -${
          toString (10 - 2 * config.wayland.windowManager.hyprland.settings.config.general.border_size)
        }px;
      }

      .notification {
        background: ${colors.extra.terminal.background};
        border: ${toString config.wayland.windowManager.hyprland.settings.config.general.border_size}px solid ${colors.normal.accent};
        border-radius: ${toString config.wayland.windowManager.hyprland.settings.config.decoration.rounding}px;
        padding: 10px;
      }

      .summary {
        font-size: 16px;
        font-weight: bold;
        background: transparent;
        color: ${colors.normal.accent};
        text-shadow: none;
      }

      .time {
        font-size: 16px;
        font-weight: bold;
        background: transparent;
        text-shadow: none;
        margin-right: 18px;
      }

      .close-button {
        background-color: ${colors.normal.red};
        color: ${colors.extra.terminal.background};
        margin-top: 5px;
        margin-right: 5px;
        border-radius: ${toString config.wayland.windowManager.hyprland.settings.config.decoration.rounding}px;
      }

      .notification-default-action:hover,
      .notification-action:hover {
        background: transparent;
      }

      .notification.critical progress {
        background-color: ${colors.normal.red};
      }

      .notification.low progress,
      .notification.normal progress {
        background-color: ${colors.normal.accent};
      }

      .notification-group {
        background-color: transparent;
        font-size: 10px;
      }

      .notification-group-buttons {
        margin-right: 10px;
        padding-bottom: 10px;
      }

      .notification-group-close-all-button,
      .notification-group-collapse-button {
        background: ${colors.extra.terminal.border};
        border-radius: ${toString config.wayland.windowManager.hyprland.settings.config.decoration.rounding}px;
        margin: 2px;
        padding: 0;
      }

      .notification-group-close-all-button:hover {
        background: ${colors.normal.red};
      }

      .notification-group-collapse-button:hover {
        background: ${colors.normal.accent};
      }

      .widget-mpris {
        background: transparent;
        margin: 0;
      }

      .widget-mpris button {
        background-color: transparent;
        border-radius: ${toString config.wayland.windowManager.hyprland.settings.config.decoration.rounding}px;
      }

      .widget-mpris button:hover {
        background-color: ${colors.normal.accent};
      }
    '';
  };

  systemd.user = {
    services.system-checks.Service = {
      Type = "oneshot";
      ExecStart = "${script}";
    };

    timers.system-checks = {
      Timer = {
        OnBootSec = "1m";
        OnUnitActiveSec = "5m";
      };

      Install.WantedBy = [ "timers.target" ];
    };
  };
}
