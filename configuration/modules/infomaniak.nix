{ lib, config, pkgs, ... }:
let cfg = config.services.infomaniak;
in {
  options.services.infomaniak = {
    enable = lib.mkEnableOption "Infomaniak DDNS updater";
    username = lib.mkOption { type = lib.types.str; };
    password = lib.mkOption { type = lib.types.str; };
    hostnames = lib.mkOption { type = lib.types.listOf lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.username != "";
        message = "Username cannot be empty";
      }
      {
        assertion = cfg.password != "";
        message = "Password cannot be empty";
      }
      {
        assertion = lib.length cfg.hostnames >= 1;
        message = "Hostnames list cannot be empty";
      }
      {
        assertion = lib.length (lib.filter (hostname: hostname == "") cfg.hostnames) == 0;
        message = "Hostname cannot be empty";
      }
    ];

    users = {
      users.infomaniak = {
        isSystemUser = true;
        group = "infomaniak";
      };

      groups.infomaniak = { };
    };

    systemd.services = lib.listToAttrs (map (hostname:
      lib.nameValuePair "infomaniak-${lib.replaceStrings [ "." ] [ "-" ] hostname}" {
        after = [ "network.target" ];
        description = "Infomaniak DDNS updater";
        serviceConfig = {
          ExecStart = ''${pkgs.curl}/bin/curl -s "https://${cfg.username}:${cfg.password}@infomaniak.com/nic/update?hostname=${hostname}"'';
          Restart = "on-abort";
          User = "infomaniak";
        };
        startAt = "*:*:0/5";
      }) cfg.hostnames);
  };
}
