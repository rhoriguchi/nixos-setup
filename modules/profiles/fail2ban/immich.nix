{
  config,
  lib,
  pkgs,
  ...
}:
let
  format = pkgs.formats.ini { };
in
{
  config = lib.mkIf config.services.immich.enable {
    services.fail2ban = {
      enable = true;

      jails.immich.settings = {
        filter = "immich";
        action = "%(banaction_allports)s";
      };
    };

    environment.etc."fail2ban/filter.d/immich.local".source = format.generate "immich.local" {
      INCLUDES.before = "common.conf";

      Definition = {
        failregex = "^.*Failed login attempt for user <F-USER>.*</F-USER> from ip address <ADDR>.*$";
        journalmatch = "_SYSTEMD_UNIT=immich-server.service";
      };

      Init.datepattern = "%%m/%%d/%%Y, %%H:%%M:%%S %%p";
    };
  };
}
