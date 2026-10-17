{
  config,
  lib,
  pkgs,
  ...
}:
let
  format = pkgs.formats.ini { };

  instanceNames = lib.attrNames (
    lib.filterAttrs (_: instance: instance.enable) config.services.authelia.instances
  );
in
{
  config = lib.mkIf (instanceNames != [ ]) {
    services.fail2ban = {
      enable = true;

      jails.authelia.settings = {
        filter = "authelia";
        action = "%(banaction_allports)s";
      };
    };

    # https://www.authelia.com/overview/security/measures/#more-protections-measures-with-fail2ban
    environment.etc."fail2ban/filter.d/authelia.local".source = format.generate "authelia.local" {
      INCLUDES.before = "common.conf";

      Definition = {
        failregex = ''
          ^.*Unsuccessful (1FA|TOTP|Duo|U2F) authentication attempt by user .*remote_ip"?(:|=)"?<HOST>"?.*$
          ^.*user not found.*path=/api/reset-password/identity/start remote_ip"?(:|=)"?<HOST>"?.*$
          ^.*Sending an email to user.*path=/api/.*/start remote_ip"?(:|=)"?<HOST>"?.*$
        '';

        journalmatch = lib.concatMapStringsSep "\n" (
          name: "_SYSTEMD_UNIT=${if name == "" then "authelia" else "authelia-${name}"}.service"
        ) instanceNames;
      };
    };
  };
}
