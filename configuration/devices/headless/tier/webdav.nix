{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  rootBindmountDir = "/mnt/bindmount/webdav";
  bindmountDir = "${rootBindmountDir}/sync-Signal-backup";
in
{
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems.${bindmountDir} = {
    depends = [ config.services.syncthing.dataDir ];
    device = "${config.services.syncthing.dataDir}/Storage/Signal backup";
    fsType = "fuse.bindfs";
    noCheck = true;
    options = [
      "map=${
        lib.concatStringsSep ":" [
          "${config.services.syncthing.user}/${config.services.webdav.user}"
          "@${config.services.syncthing.group}/@${config.services.webdav.group}"
        ]
      }"
    ];
  };

  systemd.tmpfiles.rules = [
    "d ${rootBindmountDir} 0750 ${config.services.webdav.user} ${config.services.webdav.group}"
    "d ${bindmountDir} 0750 ${config.services.webdav.user} ${config.services.webdav.group}"
  ];

  services = {
    webdav = {
      enable = true;

      settings = {
        address = "127.0.0.1";
        port = 6065;

        behindProxy = true;

        directory = bindmountDir;
        permissions = "CRUD";

        users = [
          {
            username = "admin";
            password = secrets.webdav.users.admin.password;
          }
        ];
      };
    };

    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [
        "webdav.00a.ch"
      ];
    };

    nginx = {
      enable = true;

      virtualHosts."webdav.00a.ch" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;

        extraConfig = ''
          client_max_body_size 2G;
        '';

        locations."/".proxyPass = "http://127.0.0.1:${toString config.services.webdav.settings.port}";
      };
    };
  };
}
