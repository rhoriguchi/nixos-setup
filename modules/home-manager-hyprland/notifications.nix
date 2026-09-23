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

      control-center-margin-top = 0;
      control-center-margin-bottom = 0;
      control-center-margin-right = 0;
      control-center-margin-left = 0;
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
        background-color: alpha(${colors.extra.terminal.background}, 0.85);
        border: 1px solid ${colors.normal.accent};
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

      .notification-background {
        padding: 6px 0;
      }

      .notification-group-headers {
        margin: 0;
      }

      .notification {
        background: ${colors.extra.terminal.background};
        border: 1px solid ${colors.normal.accent};
        border-radius: 8px;
        padding: 10px;
      }

      .summary {
        font-size: 16px;
        font-weight: bold;
        background: transparent;
        color: ${colors.normal.white};
        text-shadow: none;
      }

      .time {
        font-size: 16px;
        font-weight: bold;
        background: transparent;
        text-shadow: none;
        margin-right: 30px;
      }

      .close-button {
        background-color: ${colors.normal.red};
        color: ${colors.extra.terminal.background};
        min-width: 22px;
        min-height: 22px;
        margin-top: 12px;
        margin-right: 12px;
        border-radius: 8px;
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
        margin: 0;
        padding-bottom: 10px;
      }

      .notification-group-close-all-button,
      .notification-group-collapse-button {
        background: ${colors.extra.terminal.border};
        border-radius: 8px;
        min-width: 32px;
        min-height: 32px;
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
        border-radius: 8px;
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
