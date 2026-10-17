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
  config = lib.mkIf config.services.home-assistant.enable {
    services.fail2ban = {
      enable = true;

      jails.home-assistant.settings = {
        filter = "home-assistant";
        action = "%(banaction_allports)s";
      };
    };

    # https://www.home-assistant.io/integrations/fail2ban/#create-a-filter-for-the-home-assistant-jail
    environment.etc."fail2ban/filter.d/home-assistant.local".source =
      format.generate "home-assistant.local"
        {
          INCLUDES.before = "common.conf";

          Definition = {
            failregex = "^%(__prefix_line)s.*Login attempt or request with invalid authentication from <HOST>.*$";
            journalmatch = "_SYSTEMD_UNIT=home-assistant.service";
          };
        };
  };
}
