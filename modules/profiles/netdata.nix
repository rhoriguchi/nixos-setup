{ config, ... }:
{
  sops = {
    secrets."services/netdata/apiKey" = { };

    templates."services.netdata.streamConf" = {
      content = config.services.custom-netdata.streamConf.text;

      owner = config.services.netdata.user;
      group = config.services.netdata.group;

      restartUnits = [ config.systemd.services.netdata.name ];
    };
  };

  services.custom-netdata = {
    enable = true;

    type = "child";
    parentHostname = "XXLPitu-Tier";
    streamConf = {
      apiKey = config.sops.placeholder."services/netdata/apiKey";
      file = config.sops.templates."services.netdata.streamConf".path;
    };
  };
}
