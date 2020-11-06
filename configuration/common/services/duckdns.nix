{ lib, config, pkgs, ... }:
with lib;
let cfg = config.duckdns;
in {
  options.duckdns = {
    enable = mkEnableOption "Duck DNS";

    token = mkOption { type = types.str; };

    subdomain = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
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
