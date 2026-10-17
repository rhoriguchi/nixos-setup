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
  config = lib.mkIf config.services.nginx.enable {
    services.fail2ban = {
      enable = true;

      jails = {
        nginx-basic-auth.settings = {
          filter = "nginx-basic-auth";
          action = "%(banaction_allports)s";
        };

        nginx-forbidden.settings = {
          filter = "nginx-forbidden";
          action = "%(banaction_allports)s";

          bantime = "1d";
        };

        nginx-4xx.settings = {
          filter = "nginx-4xx";
          action = "%(banaction_allports)s";

          backend = "auto";
          logpath = "%(nginx_access_log)s";
        };
      };
    };

    environment.etc = {
      "fail2ban/filter.d/nginx-basic-auth.local".source = format.generate "nginx-basic-auth.local" {
        INCLUDES.before = "nginx-error-common.conf";

        Definition = {
          failregex = ''%(__prefix_line)suser "<F-USER>.*</F-USER>" was not found in "\/nix\/store\/.*\.htpasswd", client: <HOST>,.*$'';
          journalmatch = "_SYSTEMD_UNIT=nginx.service + _COMM=nginx";
        };
      };

      "fail2ban/filter.d/nginx-4xx.local".source = format.generate "nginx-4xx.local" {
        Definition.failregex = ''^<HOST> - \S+ \[\] "[^"]*" 4(?!44)\d\d'';
      };
    };
  };
}
