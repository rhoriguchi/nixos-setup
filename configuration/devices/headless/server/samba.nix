{ config, lib, pkgs, secrets, ... }:
let
  user = "samba";
  group = "samba";

  rootBindmountDir = "/mnt/bindmount/samba";
  bindmountDir = "${rootBindmountDir}/resilio-Series";
in {
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems.${bindmountDir} = {
    depends = [ config.services.resilio.syncPath ];
    device = "${config.services.resilio.syncPath}/Series";
    fsType = "fuse.bindfs";
    options = [
      # `ro` causes kernel panic
      "perms=0550"
      "map=${lib.concatStringsSep ":" [ "${config.services.resilio.user}/${user}" "@${config.services.resilio.group}/@${group}" ]}"
    ];
  };

  system.activationScripts.bindmount-samba = ''
    mkdir -p ${bindmountDir}
    chown -R ${user}:${group} ${rootBindmountDir}
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

      Series = {
        "path" = bindmountDir;
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

    startAt = "hourly";
  };

  networking.firewall.allowedTCPPorts = [ 445 ];
}
