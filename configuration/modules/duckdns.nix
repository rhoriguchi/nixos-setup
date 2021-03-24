{ lib, config, pkgs, ... }:
let cfg = config.services.duckdns;
in {
  options.services.duckdns = {
    enable = lib.mkEnableOption "Duck DNS";
    token = lib.mkOption { type = lib.types.str; };
    subdomain = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.token != "";
        message = "Token cannot be empty.";
      }
      {
        assertion = cfg.subdomain != "";
        message = "Subdomain cannot be empty.";
      }
    ];

    users.users.duckdns.isSystemUser = true;

    systemd.services.duckdns = {
      after = [ "network.target" ];
      description = "Duck DNS";
      serviceConfig = {
        ExecStart =
          "${pkgs.curl}/bin/curl -s https://www.duckdns.org/update?domains=${cfg.subdomain}&token=${cfg.token}&ip=";
        Restart = "on-abort";
        User = "duckdns";
      };
      startAt = "*:0/5";
    };
  };
}
