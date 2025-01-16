{ config, lib, pkgs, secrets, ... }:
let
  rootBindmountDir = "/mnt/bindmount/${config.services.immich.user}";
  bindmountDir = "${rootBindmountDir}/resilio-Google_Photos";
in {
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems.${bindmountDir} = {
    device = "${config.services.resilio.syncPath}/Google_Photos/photos";
    fsType = "fuse.bindfs";
    options = [
      # `ro` causes kernel panic
      "perms=0550"
      "map=${
        lib.concatStringsSep ":" [
          "${config.services.resilio.user}/${config.services.immich.user}"
          "@${config.services.resilio.group}/@${config.services.immich.group}"
        ]
      }"
    ];
  };

  system.activationScripts.immich = ''
    mkdir -p ${bindmountDir}
    chown -R ${config.services.immich.user}:${config.services.immich.group} ${rootBindmountDir}
  '';

  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "immich.00a.ch" ];
    };

    nginx = {
      enable = true;

      virtualHosts."immich.00a.ch" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.immich.port}";
          proxyWebsockets = true;

          extraConfig = ''
            proxy_buffering off;
            client_max_body_size 50000M;
          '';
        };
      };
    };

    immich = {
      enable = true;

      host = "127.0.0.1";
    };
  };
}
