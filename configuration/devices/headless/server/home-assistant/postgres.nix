{ config, ... }: {
  services = {
    home-assistant.config.recorder.db_url = "postgresql://:${toString config.services.postgresql.port}/hass";

    postgresql = {
      enable = true;

      port = 5433;

      ensureDatabases = [ "hass" ];
      ensureUsers = [{
        name = "hass";
        ensurePermissions."DATABASE hass" = "ALL PRIVILEGES";
      }];
    };
  };
}
