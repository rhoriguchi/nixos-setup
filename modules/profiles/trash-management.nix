{ pkgs, ... }:
{
  systemd.user = {
    services.trash-management = {
      after = [ "default.target" ];

      script = ''
        ${pkgs.autotrash}/bin/autotrash --days 30 --stat
        ${pkgs.autotrash}/bin/autotrash --days 30
      '';

      serviceConfig.Type = "oneshot";

      startAt = "daily";
    };

    timers.trash-management.timerConfig.Persistent = true;
  };

  programs.dconf.profiles.user.databases = [
    {
      lockAll = true;

      settings."org/gnome/desktop/privacy".remove-old-trash-files = false;
    }
  ];
}
