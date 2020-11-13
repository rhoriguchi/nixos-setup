{ lib, config, pkgs, ... }:
with lib;
let cfg = config.log2ram;
in {
  options.log2ram = {
    enable = mkEnableOption "Log2Ram";
    ram = mkOption {
      default = 60;
      type = types.ints.positive;
      description = ''
        Size for the ram folder, it defines the size the log folder will reserve into the RAM.
        If it's not enough, log2ram will not be able to use ram. Check you /var/log size folder.
      '';
    };
    mail = mkOption {
      default = false;
      type = types.bool;
      description =
        "If there are some errors with available RAM space, a system mail will be send. Change it to false and you will have only a log if there is no place on RAM anymore.";
    };
    pathToDisk = mkOption {
      default = [ "/var/log" ];
      type = types.listOf types.str;
      description =
        "Variable for folders to put in RAM. You need to specify the real folder `/path/folder`, the `/path/hdd.folder` will be automatically created.";
      example = [ "/var/log" "/home/test/FolderInRam" ];
    };
    zl2r = mkOption {
      default = false;
      type = types.bool;
      description =
        "ZL2R Zram Log 2 Ram enables a zram drive when ZL2R=true ZL2R=false is mem only tmpfs";
    };
    compressionAlgorithm = mkOption {
      default = "lz4";
      type = types.str;
      description = ''
        Can be any algorithm listed in /proc/crypto.
        lz4 is fastest with lightest load but deflate (zlib) and Zstandard (zstd) give far better compression ratios
        lzo is very close to lz4 and may with some binaries have better optimisation
        lz4 for speed or Zstd for compression, lzo or zlib if optimisation or availabilty is a problem
      '';
    };
    logDiskSize = mkOption {
      default = 150;
      type = types.ints.positive;
      description = ''
        Uncompressed disk size. Note zram uses about 0.1% of the size of the disk when not in use
        Expected compression ratio of alg chosen multiplied by log size
        lzo/lz4=2.1:1 compression ratio zlib=2.7:1 zstandard=2.9:1
        Really a guestimate of a bit bigger than compression ratio whilst minimising 0.1% mem usage of disk size
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.compressionAlgorithm != "";
        message = "Compression algorithm cannot be empty.";
      }
      {
        assertion =
          builtins.length (builtins.filter (match: match == "") cfg.pathToDisk)
          == 0;
        message = "Path to disk elements can't have empty value";
      }
      {
        assertion = builtins.length
          (builtins.filter (match: strings.hasSuffix "/" match) cfg.pathToDisk)
          == 0;
        message = "Path to disk elements can't have '/' suffix";
      }
    ];

    environment.etc."log2ram.conf".text = ''
      SIZE=${toString cfg.ram}M
      MAIL=${if cfg.mail == false then "false" else "true"}
      PATH_DISK="${builtins.concatStringsSep ";" cfg.pathToDisk}"
      ZL2R=${if cfg.zl2r == false then "false" else "true"}
      COMP_ALG=${cfg.compressionAlgorithm}
      LOG_DISK_SIZE=${toString cfg.logDiskSize}M
    '';

    # TODO run after every rebuild
    system.activationScripts.rslsync = ''
      rm -rf /var/log.hdd
      rm -rf /var/hdd.log
    '';

    systemd.services = {
      log2ram = {
        after = [ "local-fs.target" ];
        before = [
          "apache2.service"
          "basic.target"
          "lighttpd.service"
          "rsyslog.service"
          "shutdown.target"
          "sysinit.target"
          "syslog-ng.service"
          "syslog.target"
          "systemd-journald.service"
          "zram-swap-conf.service"
        ];
        conflicts = [ "shutdown.target" "reboot.target" "halt.target" ];
        description = "Log2Ram";
        serviceConfig = {
          ExecReload = "${pkgs.log2ram}/bin/log2ram write";
          ExecStart = "${pkgs.log2ram}/bin/log2ram start";
          ExecStop = "${pkgs.log2ram}/bin/log2ram stop";
          RemainAfterExit = true;
          TimeoutStartSec = 120;
          Type = "oneshot";
        };
        unitConfig = {
          DefaultDependencies = "no";
          RequiresMountsFor = [ "/var/log" "/var/hdd.log" ];
        };
        wantedBy = [ "sysinit.target" ];
      };

      log2ram-daily = {
        after = [ "log2ram.service" ];
        description = "Daily Log2Ram writing activities";
        serviceConfig = { ExecStart = "systemctl reload log2ram.service"; };
        startAt = "daily";
      };
    };
  };
}
