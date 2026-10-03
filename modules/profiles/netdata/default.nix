{ config, ... }:
{
  imports = [ ./containers.nix ];

  sops = {
    secrets."services/netdata/apiKey" = { };

    templates."services.netdata.streamConf" = {
      content = config.services.custom-netdata.streamConf.text;

      owner = config.services.netdata.user;
      group = config.services.netdata.group;

      reloadUnits = [ config.systemd.services.netdata.name ];
    };
  };

  services.custom-netdata = {
    enable = true;

    parent.enable = config.containers != { };

    child = {
      enable = true;
      parentHostname = "XXLPitu-Tier";
    };

    streamConf = {
      apiKey = config.sops.placeholder."services/netdata/apiKey";
      file = config.sops.templates."services.netdata.streamConf".path;
    };
  };
}
