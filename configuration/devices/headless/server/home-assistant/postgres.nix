{ config, ... }: {
  services = {
    home-assistant.config.recorder.db_url = "postgresql://:${toString config.services.postgresql.port}/hass";

    postgresql = {
      enable = true;

      ensureDatabases = [ "hass" ];
      ensureUsers = [{
        name = "hass";
        ensureDBOwnership = true;
      }];
    };
  };
}
