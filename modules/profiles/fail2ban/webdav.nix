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
  config = lib.mkIf config.services.webdav.enable {
    services.fail2ban = {
      enable = true;

      jails.webdav.settings = {
        filter = "webdav";
        action = "%(banaction_allports)s";
      };
    };

    # https://github.com/hacdias/webdav#fail2ban-setup
    environment.etc."fail2ban/filter.d/webdav.local".source = format.generate "webdav.local" {
      INCLUDES.before = "common.conf";

      Definition = {
        failregex = ''
          ^.*invalid password\s+\{.*"remote_address":\s*"<HOST>(?::\d+)?".*\}$
          ^.*invalid username\s+\{.*"remote_address":\s*"<HOST>(?::\d+)?".*\}$
        '';

        journalmatch = "_SYSTEMD_UNIT=webdav.service";
      };
    };
  };
}
