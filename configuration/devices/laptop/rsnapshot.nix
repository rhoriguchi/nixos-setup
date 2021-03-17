{ pkgs, ... }:
let
  backupDir = "/media/Backup";

  excludeFile = pkgs.writeText "default.exclude" ''
    # JetBrains
    - /**.idea

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

  rsyncLongArgs = builtins.concatStringsSep " " [
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
    "--stats"
    "--times"
    "--verbose"
  ];
in {
  fileSystems."${backupDir}" = {
    device = "/dev/disk/by-uuid/39330EF715A92911";
    fsType = "ntfs";
    options = [
      "defaults"
      "mode=0777"
      "nofail"
      "umask=0000"
      "x-systemd.automount"
      "x-systemd.device-timeout=1ms"
      "x-systemd.idle-timeout=1min"
    ];
  };

  system.activationScripts.createBackupDir =
    "${pkgs.coreutils}/bin/mkdir -pm 0777 ${backupDir}";

  services.rsnapshot = {
    enable = true;

    enableManualRsnapshot = true;
    extraConfig = ''
      verbose	4
      no_create_root	1
      rsync_long_args	${rsyncLongArgs}

      snapshot_root	${backupDir}/snapshot/Laptop

      exclude_file	${excludeFile}

      retain	manual	5

      backup	/etc/nixos/	localhost/
      backup	/home/rhoriguchi/	localhost/
      backup	/media/Data/Downloads/	localhost/
      backup	/media/Data/Sync/	localhost/
    '';
  };
}
