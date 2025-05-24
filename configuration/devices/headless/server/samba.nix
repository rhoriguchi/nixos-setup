{ config, lib, pkgs, secrets, ... }:
let
  user = "samba";
  group = "samba";

  rootBindmountDir = "/mnt/bindmount/samba";
  bindmountDir1 = "${rootBindmountDir}/resilio-Movies";
  bindmountDir2 = "${rootBindmountDir}/resilio-Series";
  bindmountDir3 = "${rootBindmountDir}/disk-Movies";
  bindmountDir4 = "${rootBindmountDir}/disk-Series";

  rootOverlayDir = "/mnt/overlay/samba";
  overlayDir1 = "${rootOverlayDir}/Movies";
  overlayDir2 = "${rootOverlayDir}/Series";
in {
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems = {
    "${bindmountDir1}" = {
      depends = [ config.services.resilio.syncPath ];
      device = "${config.services.resilio.syncPath}/Movies";
      fsType = "fuse.bindfs";
      options = [
        # `ro` causes kernel panic
        "perms=0550"
        "map=${lib.concatStringsSep ":" [ "${config.services.resilio.user}/${user}" "@${config.services.resilio.group}/@${group}" ]}"
      ];
    };

    "${bindmountDir2}" = {
      depends = [ config.services.resilio.syncPath ];
      device = "${config.services.resilio.syncPath}/Series";
      fsType = "fuse.bindfs";
      options = [
        # `ro` causes kernel panic
        "perms=0550"
        "map=${lib.concatStringsSep ":" [ "${config.services.resilio.user}/${user}" "@${config.services.resilio.group}/@${group}" ]}"
      ];
    };

    "${bindmountDir3}" = {
      depends = [ "/mnt/Data/Movies" ];
      device = "/mnt/Data/Movies";
      fsType = "fuse.bindfs";
      options = [
        # `ro` causes kernel panic
        "perms=0550"
        "map=${lib.concatStringsSep ":" [ "root/${user}" "@root/@${group}" ]}"
      ];
    };

    "${bindmountDir4}" = {
      depends = [ "/mnt/Data/Series" ];
      device = "/mnt/Data/Series";
      fsType = "fuse.bindfs";
      options = [
        # `ro` causes kernel panic
        "perms=0550"
        "map=${lib.concatStringsSep ":" [ "root/${user}" "@root/@${group}" ]}"
      ];
    };

    "${overlayDir1}".overlay.lowerdir = [ bindmountDir1 bindmountDir3 ];

    "${overlayDir2}".overlay.lowerdir = [ bindmountDir2 bindmountDir4 ];
  };

  system.activationScripts.bindmount-overlay-samba = ''
    mkdir -p ${bindmountDir1}
    mkdir -p ${bindmountDir2}
    mkdir -p ${bindmountDir3}
    mkdir -p ${bindmountDir4}
    chown -R ${user}:${group} ${rootBindmountDir}

    mkdir -p ${overlayDir1}
    mkdir -p ${overlayDir2}
    chown ${user}:${group} ${rootOverlayDir}
  '';

  users = {
    users.${user} = {
      isSystemUser = true;
      inherit group;
    };

    groups.${group} = { };
  };

  services.samba = {
    enable = true;
    winbindd.enable = false;

    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = config.networking.hostName;

        "hosts allow" = [ "192.168." "127.0.0.1" ] ++ lib.optional config.networking.enableIPv6 "::1";

        "security" = "user";
        "invalid users" = [ "root" ];
        "passdb backend" = "tdbsam";
        "obey pam restrictions" = "yes";
        "pam password change" = "yes";

        "map to guest" = "Never";
        "restrict anonymous" = 2;

        "server min protocol" = "SMB2";
        "client min protocol" = "SMB2";

        "disable netbios" = "yes";
        "wins support" = "no";

        "smb encrypt" = "required";
        "client ipc signing" = "mandatory";
        "server signing" = "mandatory";
        "client signing" = "mandatory";

        # Enable server-side copy for macOS clients
        "fruit:copyfile" = "yes";

        # Disable printer support
        "load printers" = "no";
        "printing" = "bsd";
        "printcap name" = "/dev/null";
        "disable spoolss" = "yes";
        "show add printer wizard" = "no";
      };

      Media = {
        "path" = rootOverlayDir;
        "browseable" = "yes";
        "read only" = "yes";

        "valid users" = [ user ];
        "force user" = user;
        "force group" = group;

        "veto files" = lib.concatStringsSep "/" [ ".sync" ];
      };
    };
  };

  systemd.services.add-samba-users = {
    after = [ "network.target" "smbd.service" ];

    script = lib.concatStringsSep "\n" (lib.mapAttrsToList (key: value: ''
      ${pkgs.expect}/bin/expect <<EOF
      spawn ${config.services.samba.package}/bin/smbpasswd -a ${key}
      expect "New SMB password:"
      send "${value.password}\n"
      expect "Retype new SMB password:"
      send "${value.password}\n"
      send "quit\n"
      interact
      EOF

      ${config.services.samba.package}/bin/smbpasswd -e ${key}
    '') secrets.samba.users);

    serviceConfig.Type = "oneshot";

    startAt = "hourly";
  };

  networking.firewall.allowedTCPPorts = [ 445 ];
}
