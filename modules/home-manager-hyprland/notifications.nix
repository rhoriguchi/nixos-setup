{ colors, config, ... }:
{
  # TODO HYPRLAND notification when low battery < 15%
  # TODO HYPRLAND notification when disk 90% full

  services.swaync = {
    enable = true;

    # https://github.com/ErikReider/SwayNotificationCenter/blob/main/src/configSchema.json
    settings = {
      notification-inline-replies = true;
      notification-icon-size = 48;
      notification-body-image-height = 160;
      notification-body-image-width = 200;
      notification-window-width = 400;

      control-center-margin-top = config.wayland.windowManager.hyprland.settings.general.gaps_out;
      control-center-margin-bottom = config.wayland.windowManager.hyprland.settings.general.gaps_out;
      control-center-margin-right = config.wayland.windowManager.hyprland.settings.general.gaps_out;
      control-center-margin-left = config.wayland.windowManager.hyprland.settings.general.gaps_out;
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
        border: ${toString config.wayland.windowManager.hyprland.settings.general.border_size}px solid ${colors.normal.accent};
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
          toString (10 - 2 * config.wayland.windowManager.hyprland.settings.general.border_size)
        }px;
      }

      .notification {
        background: ${colors.extra.terminal.background};
        border: ${toString config.wayland.windowManager.hyprland.settings.general.border_size}px solid ${colors.normal.accent};
        border-radius: ${toString config.wayland.windowManager.hyprland.settings.decoration.rounding}px;
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
        border-radius: ${toString config.wayland.windowManager.hyprland.settings.decoration.rounding}px;
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
        border-radius: ${toString config.wayland.windowManager.hyprland.settings.decoration.rounding}px;
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
        border-radius: ${toString config.wayland.windowManager.hyprland.settings.decoration.rounding}px;
      }

      .widget-mpris button:hover {
        background-color: ${colors.normal.accent};
      }
    '';
  };
}
