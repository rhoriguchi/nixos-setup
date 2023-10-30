{ lib, config, ... }: {
  services = {
    home-assistant.config.recorder.db_url = "postgresql://:${toString config.services.postgresql.port}/hass";

    postgresql = {
      enable = true;

      ensureDatabases = [ "hass" ];
      ensureUsers = [{
        name = "hass";
        ensurePermissions."DATABASE hass" = "ALL PRIVILEGES";
      }];
    };
  };

  # TODO remove when fixed https://github.com/NixOS/nixpkgs/issues/216989
  # workaround from https://github.com/NixOS/nixpkgs/pull/262741
  systemd.services.postgresql.postStart = lib.mkAfter ''
    $PSQL -tAc 'ALTER DATABASE hass OWNER TO hass;'
  '';
}
