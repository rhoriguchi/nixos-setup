{ config, lib, pkgs, ... }:
let format = pkgs.formats.ini { };
in {
  services.fail2ban = {
    enable = lib.any (service: service.enable) [ config.services.home-assistant config.services.immich config.services.nginx ];

    ignoreIP = [ "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" ];

    bantime = "1h";

    bantime-increment = {
      enable = true;

      multipliers = "1 2 4 8 16 32 64";
      maxtime = "${toString (7 * 24)}h";
    };

    maxretry = 3;

    jails = {
      home-assistant = {
        enabled = config.services.home-assistant.enable;

        settings = {
          filter = "home-assistant";
          action = "%(banaction_allports)s";

          logpath = "/var/lib/hass/home-assistant.log";
        };
      };

      immich = {
        enabled = config.services.immich.enable;

        settings = {
          filter = "immich";
          action = "%(banaction_allports)s";
        };
      };

      nginx-basic-auth = {
        enabled = config.services.nginx.enable;

        settings = {
          filter = "nginx-basic-auth";
          action = "%(banaction_allports)s";
        };
      };

      nginx-forbidden = {
        enabled = config.services.nginx.enable;

        settings = {
          filter = "nginx-forbidden";
          action = "%(banaction_allports)s";

          bantime = "1d";
        };
      };
    };
  };

  environment.etc = {
    # https://www.home-assistant.io/integrations/fail2ban/#create-a-filter-for-the-home-assistant-jail
    "fail2ban/filter.d/home-assistant.local".source = format.generate "home-assistant.local" {
      INCLUDES.before = "common.conf";

      Definition.failregex = "^%(__prefix_line)s.*Login attempt or request with invalid authentication from <HOST>.*$";

      Init.datepattern = "%%Y-%%m-%%d %%H:%%M:%%S";
    };

    "fail2ban/filter.d/immich.local".source = format.generate "immich.local" {
      INCLUDES.before = "common.conf";

      Definition.failregex = "^.*Failed login attempt for user <F-USER>.*</F-USER> from ip address <ADDR>.*$";

      Init.datepattern = "%%m/%%d/%%Y, %%H:%%M:%%S %%p";
    };

    "fail2ban/filter.d/nginx-basic-auth.local".source = format.generate "nginx-basic-auth.local" {
      INCLUDES.before = "nginx-error-common.conf";

      Definition.failregex =
        ''%(__prefix_line)suser "<F-USER>.*</F-USER>" was not found in "\/nix\/store\/.*\.htpasswd", client: <HOST>,.*$'';

      Init.datepattern = "{^LN-BEG}";
    };
  };
}
