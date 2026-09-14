{
  config,
  lib,
  ...
}:
{
  sops = {
    secrets = {
      "services/netdata/claimToken".restartUnits = [ config.systemd.services.netdata.name ];
      "services/netdata/discordWebhookUrl" = { };
    };

    templates."services.netdata.healthAlarmNotify" = {
      content = config.services.custom-netdata.healthAlarmNotify.text;

      owner = config.services.netdata.user;
      group = config.services.netdata.group;
    };
  };

  services = {
    nginx = {
      enable = true;

      virtualHosts."netdata.00a.ch" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;

        extraConfig = ''
          include /run/nginx-authelia/location.conf;
        '';

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.custom-netdata.webPort}";

          extraConfig = ''
            include /run/nginx-authelia/auth.conf;
          '';
        };
      };
    };

    infomaniak = {
      enable = true;

      hostnames = [ "netdata.00a.ch" ];
    };

    custom-netdata = {
      enable = true;

      type = lib.mkForce "parent";

      claimTokenFile = config.sops.secrets."services/netdata/claimToken".path;

      healthAlarmNotify = {
        file = config.sops.templates."services.netdata.healthAlarmNotify".path;
        discordWebhookUrl = config.sops.placeholder."services/netdata/discordWebhookUrl";
      };
    };
  };
}
