{ pkgs, lib, config, ... }:
let
  backupDir = "/mnt/Backup";
  snapshotDir = "${backupDir}/snapshot/Laptop";
  keyPath = "${config.users.users.rhoriguchi.home}/Sync/Storage/Luks/backup.key";

  preExecShellScript = pkgs.writeShellScript "rsnapshot-preExec" ''
    mkdir -p "${backupDir}"

    ${pkgs.cryptsetup}/bin/cryptsetup luksOpen --key-file "${keyPath}" /dev/disk/by-uuid/792d67dc-3de4-4790-9e51-ec281e28b0d1 backup
    mountpoint -q "${backupDir}" || mount "/dev/mapper/backup" "${backupDir}"

    rm -rf "${backupDir}/.Trash-*" || true
    mkdir -p "${snapshotDir}"
  '';

  postExecShellScript = pkgs.writeShellScript "rsnapshot-postExec" ''
    rm -rf "${backupDir}/.Trash-*" || true

    umount ${backupDir} || true
    ${pkgs.cryptsetup}/bin/cryptsetup luksClose backup || true
  '';

  excludeFile = pkgs.writeText "rsnapshot-default.exclude" (let
    excludedDirs = [
      # eCryptfs
      ".ecryptfs"
      ".Private"

      # Trash
      ".local/share/Trash"
      ".Trash-*"

      # Containers
      ".local/share/containers"

      # Cache
      ".cache"

      # Nix
      ".nix-defexpr"

      # Node
      "node_modules"

      # Maven
      ".m2"
      "target/classes"
      "target/generated-sources"
      "target/generated-test-sources"
      "target/test-classes"

      # Steam
      ".steam"
      "Steam/steamapps"

      # Resilio Sync
      ".sync"

      # Wine
      ".wine"

      # Security
      ".docker/config.json"
      ".git-credentials"
      ".gnupg"
      ".ssh"
    ];
  in lib.concatStringsSep "\n" (map (dir: "- /**${dir}") excludedDirs));

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

      snapshot_root	${snapshotDir}

      exclude_file	${excludeFile}

      retain	manual	5

      backup	${config.users.users.rhoriguchi.home}/	./
    '';
  };
}
