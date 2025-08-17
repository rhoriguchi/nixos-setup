{ config, lib, modulesPath, pkgs, ... }:
let
  listeningPort = 5555;

  cfg = config.services.resilio;

  sharedFolders = lib.attrValues (lib.mapAttrs (key: value: {
    secret = if lib.elem key cfg.readWriteDirs then value.readWrite else value.encrypted;
    dir = "${lib.optionalString (cfg.syncPath != null) "${cfg.syncPath}/"}${
        if lib.elem key cfg.readWriteDirs then key else builtins.hashString "sha256" key
      }";
    use_relay_server = true;
    search_lan = true;
    use_sync_trash = false;
    overwrite_changes = true;
    selective_sync = false;
    known_hosts = [ ];
  }) cfg.secrets);

  resilioConfig = {
    device_name = lib.toUpper config.networking.hostName;
    listening_port = listeningPort;
    storage_path = cfg.storagePath;
    check_for_updates = cfg.webUI.enable;
    use_upnp = true;
    download_limit = cfg.downloadLimit;
    upload_limit = cfg.uploadLimit;
    directory_root = cfg.syncPath;
    lan_encrypt_data = true;
    send_statistics = false;
    peer_expiration_days = 1;
    use_gui = false;
    disk_low_priority = true;
  } // (if cfg.webUI.enable then {
    webui = {
      login = cfg.webUI.username;
      password = cfg.webUI.password;
      listen = "127.0.0.1:${toString cfg.webUI.port}";
    };
  } else
    lib.optionalAttrs (lib.length sharedFolders > 0) { shared_folders = sharedFolders; });

  configFile = pkgs.writers.writeJSON "config.json" resilioConfig;
in {
  disabledModules = [ "${modulesPath}/services/networking/resilio.nix" ];

  options.services.resilio = {
    enable = lib.mkEnableOption "Resilio Sync";
    user = lib.mkOption {
      type = lib.types.str;
      default = "rslsync";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "rslsync";
    };
    webUI = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          username = lib.mkOption {
            type = lib.types.str;
            default = "admin";
          };
          password = lib.mkOption { type = lib.types.str; };
          port = lib.mkOption {
            type = lib.types.port;
            default = 8888;
          };
        };
      };
      default = { };
    };
    systemWide = lib.mkOption {
      type = lib.types.bool;
      default = !cfg.webUI.enable;
    };
    syncPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
    storagePath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = if cfg.systemWide then "/var/lib/resilio-sync" else null;
    };
    logging = lib.mkOption {
      type = lib.types.submodule {
        options = {
          debug = lib.mkOption {
            type = lib.types.bool;
            default = cfg.systemWide;
          };
          filePath = lib.mkOption {
            type = lib.types.path;
            default = "/var/log/resilio-sync/sync.log";
          };
        };
      };
      default = { };
    };
    downloadLimit = lib.mkOption {
      type = lib.types.int;
      # kB/s
      default = 0;
    };
    uploadLimit = lib.mkOption {
      type = lib.types.int;
      # kB/s
      default = 0;
    };
    readWriteDirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    secrets = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          encrypted = lib.mkOption {
            default = null;
            type = lib.types.nullOr (lib.types.strMatching "^F[0-9A-Z]{32}$");
          };
          readWrite = lib.mkOption {
            default = null;
            type = lib.types.nullOr (lib.types.strMatching "^D[0-9A-Z]{32}$");
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.syncPath != "";
        message = "Sync path cannot be empty";
      }
      {
        assertion = cfg.systemWide -> !cfg.webUI.enable;
        message = "When running system wide web ui can't be enabled";
      }
      {
        assertion = cfg.systemWide -> cfg.storagePath != null;
        message = "When running system wide storagePath can't be null";
      }
      {
        assertion = cfg.systemWide -> cfg.syncPath != null;
        message = "When running system wide syncPath can't be null";
      }
      {
        assertion = !cfg.systemWide -> !cfg.logging.debug;
        message = "When not running system wide debug logging can't be enabled";
      }
      {
        assertion = !cfg.systemWide -> cfg.storagePath == null;
        message = "When not running system wide storagePath can't be set";
      }
      {
        assertion = !cfg.systemWide -> cfg.syncPath == null;
        message = "When not running system wide syncPath can't be set";
      }
      {
        assertion = cfg.webUI.enable -> cfg.webUI.username != "";
        message = "When web ui is enabled username must be set";
      }
      {
        assertion = cfg.webUI.enable -> cfg.webUI.password != "";
        message = "When web ui is enabled password must be set";
      }
      {
        assertion = !cfg.webUI.enable -> cfg.secrets != [ ];
        message = "Secrets cannot be empty";
      }
      {
        assertion = let
          flattenedSecrets = lib.flatten (map lib.attrValues (lib.attrValues cfg.secrets));
          secrets = lib.filter (secret: secret != null) flattenedSecrets;
        in secrets == lib.unique secrets;
        message = "Every secret in secrets must be unique";
      }
      {
        assertion = lib.length (lib.filter (readWriteDir: cfg.secrets.${readWriteDir}.readWrite == null) cfg.readWriteDirs) == 0;
        message = "All read write dirs need to have a readWrite secret";
      }
      {
        assertion = let encryptedDirs = lib.subtractLists cfg.readWriteDirs (lib.attrNames cfg.secrets);
        in lib.length (lib.filter (encryptedDir: cfg.secrets.${encryptedDir}.encrypted == null) encryptedDirs) == 0;
        message = "All encrypted dirs need to have an encrypted secret";
      }
    ];

    networking.nftables.tables.resilio = lib.optionalAttrs (lib.length (lib.attrNames config.networking.wireguard.interfaces) > 0) {
      family = "inet";

      content = ''
        chain input {
          type filter hook input priority filter;

          iifname { ${
            lib.concatStringsSep ", " (lib.attrNames config.networking.wireguard.interfaces)
          } } meta l4proto { tcp, udp } th dport { ${toString listeningPort} } drop
        }

        chain output {
          type filter hook output priority filter;

          oifname { ${
            lib.concatStringsSep ", " (lib.attrNames config.networking.wireguard.interfaces)
          } } meta l4proto { tcp, udp } th dport { ${toString listeningPort} } drop
        }
      '';
    };

    users = lib.mkIf cfg.systemWide {
      users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
        uid = config.ids.uids.rslsync;
        createHome = true;
        home = cfg.storagePath;
      };

      groups.${cfg.group}.gid = config.ids.gids.rslsync;
    };

    systemd = if cfg.systemWide then {
      tmpfiles.rules = [
        "d ${cfg.logging.filePath} 0711 ${cfg.user} ${cfg.group}"
        "d ${cfg.storagePath} 0775 ${cfg.user} ${cfg.group}"
        "d ${cfg.syncPath} 0775 ${cfg.user} ${cfg.group}"
      ];

      services.resilio = {
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        preStart = ''echo "${if cfg.logging.debug then "FFFFFFFF" else "80000000"}" > "${cfg.storagePath}/debug.txt"'';
        script = ''${pkgs.resilio-sync}/bin/rslsync --config ${configFile} --log "${cfg.logging.filePath}" --nodaemon'';

        serviceConfig = {
          StandardOutput = "null";
          StandardError = "null";
          Restart = "on-abort";

          UMask = "027";
          User = cfg.user;
          Group = cfg.group;
        };

        unitConfig.ConditionPathExists = [ cfg.syncPath ];
      };
    } else
      let
        userStoragePath = ".config/resilio-sync";
        userSyncPath = "Sync";

        runConfigPath = "/run/user/1000/resilio-sync-config.json";
      in {
        user.services.resilio = {
          after = [ "network.target" ];
          wantedBy = [ "default.target" ];

          script = ''${pkgs.resilio-sync}/bin/rslsync --config "${runConfigPath}" --nodaemon'';

          serviceConfig = {
            Type = "simple";
            StandardOutput = "null";
            StandardError = "null";
            Restart = "on-abort";

            # Specifiers only works in unit file
            ExecStartPre = [
              (let
                operations = [ ''.directory_root = \"%h/${userSyncPath}\"'' ''.storage_path = \"%h/${userStoragePath}\"'' ]
                  ++ lib.optional (lib.length sharedFolders > 0)
                  ''.shared_folders = [.shared_folders[] | .dir = (\"%h/${userSyncPath}/\" + .dir)]'';
                command = "${pkgs.jq}/bin/jq '${lib.concatStringsSep " | " operations}' ${configFile} > ${runConfigPath}";
              in ''${pkgs.bashInteractive}/bin/sh -c "${command}"'')

              # This needs an absolute path
              ''${pkgs.coreutils}/bin/mkdir -p "%h/${userSyncPath}" "%h/${userStoragePath}"''
            ];
          };
        };
      };
  };
}
