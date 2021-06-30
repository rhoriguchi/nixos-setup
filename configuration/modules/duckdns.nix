{ lib, config, pkgs, ... }:
let cfg = config.services.duckdns;
in {
  options.services.duckdns = {
    enable = lib.mkEnableOption "Duck DNS";
    token = lib.mkOption { type = lib.types.str; };
    subdomains = lib.mkOption { type = lib.types.listOf lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.token != "";
        message = "Token cannot be empty.";
      }
      {
        assertion = builtins.length cfg.subdomains != 0;
        message = "Subdomain list cannot be empty.";
      }
      {
        assertion = builtins.length (builtins.filter (subdomain: subdomain == "") cfg.subdomains) == 0;
        message = "Subdomain cannot be empty.";
      }
    ];

    users.users.duckdns.isSystemUser = true;

    systemd.services.duckdns = {
      after = [ "network.target" ];
      description = "Duck DNS";
      serviceConfig = {
        ExecStart = "${builtins.concatStringsSep " && "
          (map (subdomain: ''${pkgs.curl}/bin/curl -s "https://www.duckdns.org/update?domains=${subdomain}&token=${cfg.token}&ip="'')
            cfg.subdomains)}";
        Restart = "on-abort";
        User = "duckdns";
      };
      startAt = "*:0/5";
    };
  };
}
