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
        message = "Token cannot be empty";
      }
      {
        assertion = lib.length cfg.subdomains >= 1;
        message = "Subdomain list cannot be empty";
      }
      {
        assertion = lib.length (lib.filter (subdomain: subdomain == "") cfg.subdomains) == 0;
        message = "Subdomain cannot be empty";
      }
    ];

    users = {
      users.duckdns = {
        isSystemUser = true;
        group = "duckdns";
      };

      groups.duckdns = { };
    };

    systemd.services.duckdns = {
      after = [ "network.target" ];
      description = "Duck DNS";
      script = let
        commands =
          map (subdomain: ''${pkgs.curl}/bin/curl -s "https://www.duckdns.org/update?domains=${subdomain}&token=${cfg.token}&ip="'')
          cfg.subdomains;
      in lib.concatStringsSep "\n" commands;
      serviceConfig = {
        Restart = "on-abort";
        User = "duckdns";
      };
      startAt = "*:0/5";
    };
  };
}
