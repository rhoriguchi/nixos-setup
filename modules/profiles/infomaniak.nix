{ config, lib, ... }:
{
  config = lib.mkIf config.services.infomaniak.enable {
    sops.secrets."services/infomaniak/dynamicDnsUsers/nixos".restartUnits = [
      config.systemd.services.ddclient.name
    ];

    services.infomaniak.passwordFile =
      config.sops.secrets."services/infomaniak/dynamicDnsUsers/nixos".path;
  };
}
