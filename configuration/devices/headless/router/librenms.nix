{ config, lib, pkgs, secrets, ... }:
let defaultUser = "admin";
in {
  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "librenms.00a.ch" ];
    };

    # workaround for the nginx attributes since lib.mkMerge fails
    nginx.virtualHosts."${config.services.librenms.hostname}".locations."/" = {
      basicAuth = secrets.nginx.basicAuth."librenms.00a.ch";

      extraConfig = ''
        fastcgi_param REMOTE_USER ${defaultUser};

        satisfy any;

        allow 192.168.2.0/24;
        deny all;
      '';
    };

    librenms = {
      enable = true;

      hostname = "librenms.00a.ch";

      settings = {
        auth_mechanism = "http-auth";

        autodiscovery.nets-exclude = [ ];
        nets = [ "127.0.0.1" "192.168.2.0/24" ];

        prometheus = let basicAuth = secrets.nginx.basicAuth."pushgateway.00a.ch";
        in {
          enable = true;
          url = "https://pushgateway.00a.ch";
          user = builtins.head (lib.attrNames basicAuth);
          password = builtins.head (lib.attrValues basicAuth);
          job = "librenms";
          prefix = "librenms";
        };
      };

      database = {
        createLocally = true;
        socket = "/run/mysqld/mysqld.sock";
      };

      nginx = {
        enableACME = true;
        forceSSL = true;
      };
    };
  };

  systemd.services.librenms-add-admin-user = {
    after = [ "librenms-setup.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = config.services.librenms.user;
      Group = config.services.librenms.group;
    };

    script = let
      package = builtins.head (builtins.filter (package: package.name == "lnms") config.environment.systemPackages);
      lnms = "${package}/bin/lnms";
    in ''
      ${lnms} db:seed --force

      ${lnms} user:add ${
        lib.concatStringsSep " " [
          ''--email "${config.security.acme.defaults.email}"''
          ''--password "$(${pkgs.openssl}/bin/openssl rand --hex 16)"''
          "--role admin"
          "--no-interaction"
        ]
      } ${defaultUser} || true

      echo "${
        lib.concatStringsSep " " [
          "UPDATE ${config.services.librenms.database.database}.users"
          "SET auth_type = '${config.services.librenms.settings.auth_mechanism}'"
          "WHERE username = '${defaultUser}'"
        ]
      };" | ${pkgs.mariadb}/bin/mysql --socket='${config.services.librenms.database.socket}' || true
    '';
  };

  services.cron.systemCronJobs = [
    "27 * * * * ${config.services.librenms.user} ${pkgs.python3}/bin/python ${config.services.librenms.finalPackage}/snmp-scan.py >> /dev/null 2>&1"
  ];
}
