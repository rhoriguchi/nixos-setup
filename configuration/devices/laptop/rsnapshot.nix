{ pkgs, lib, config, ... }:
let
  backupDir = "/mnt/Backup";
  keyPath = "${config.services.resilio.syncPath}/Storage/Luks/backup.key";

  preExecShellScript = pkgs.writeShellScript "rsnapshot-preExec" ''
    ${pkgs.cryptsetup}/bin/cryptsetup luksOpen --key-file ${keyPath} /dev/disk/by-uuid/28ca9d71-aec7-4b19-9fd6-ab6f7cc1b186 backup
    mountpoint -q ${backupDir} || mount /dev/disk/by-uuid/84ecadcc-4fa1-4060-ac42-d774e032db77 ${backupDir}
  '';

  postExecShellScript = pkgs.writeShellScript "rsnapshot-postExec" ''
    umount ${backupDir} || true
    ${pkgs.cryptsetup}/bin/cryptsetup luksClose backup || true
  '';

  excludeFile = pkgs.writeText "rsnapshot-default.exclude" ''
    # Trash
    - /**.local/share/Trash
    - /**.Trash-1000

    # Containers
    - /**.local/share/containers

    # Cache
    - /**.cache

    # Nix
    - /**.nix-defexpr

    # Node
    - /**node_modules

    # Maven
    - /**.m2
    - /**target/classes
    - /**target/generated-sources
    - /**target/generated-test-sources
    - /**target/test-classes

    # Steam
    - /**.steam
    - /**Steam/steamapps

    # Resilio Sync
    - /**.sync

    # Wine
    - /**.wine

    # Security
    - /**.docker/config.json
    - /**.git-credentials
    - /**.gnupg
    - /**.ssh
  '';

  rsyncLongArgs = lib.concatStringsSep " " [
    # rsnapshot requires these args
    "--delete-excluded"
    "--delete"
    "--relative"
    "--numeric-ids"

    "--copy-links"
    "--force"
    "--human-readable"
    "--no-group"
    "--no-owner"
    "--no-perms"
    "--progress"
    "--recursive"
    "--times"
    "--verbose"
  ];
in {
  services.rsnapshot = {
    enable = true;

    enableManualRsnapshot = true;
    extraConfig = ''
      verbose	4
      rsync_long_args	${rsyncLongArgs}

      cmd_preexec	${preExecShellScript}
      cmd_postexec	${postExecShellScript}

      snapshot_root	${backupDir}/snapshot/Laptop

      exclude_file	${excludeFile}

      retain	manual	5

      backup	/nix/store/	./
      backup	${config.users.users.rhoriguchi.home}/	./
      backup	${config.services.resilio.syncPath}/	./
    '';
  };
}
