{ lib, config, pkgs, ... }:
let
  cfg = config.services.resilio;

  secrets = let secrets = lib.lists.flatten (map lib.attrValues (lib.attrValues cfg.secrets));
  in lib.filter (secret: secret != null) secrets;

  sharedFolders = lib.attrValues (lib.mapAttrs (key: value: {
    secret = if lib.elem key cfg.readWriteDirs then value.readWrite else value.encrypted;
    dir = "${cfg.syncPath}/${if lib.elem key cfg.readWriteDirs then key else builtins.hashString "sha256" key}";
    use_relay_server = true;
    search_lan = true;
    use_sync_trash = false;
    overwrite_changes = true;
    selective_sync = false;
    known_hosts = [ ];
  }) cfg.secrets);

  configFile = (pkgs.formats.json { }).generate "config.json" ({
    device_name = lib.toUpper cfg.deviceName;
    listening_port = cfg.listeningPort;
    storage_path = cfg.storagePath;
    check_for_updates = cfg.webUI.enable;
    use_upnp = true;
    download_limit = 0;
    upload_limit = 0;
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
      listen = "0.0.0.0:${toString cfg.webUI.port}";
    };
  } else {
    shared_folders = sharedFolders;
  }));
in {
  disabledModules = [ "services/networking/resilio.nix" ];

  options.services.resilio = {
    enable = lib.mkEnableOption "Resilio Sync";
    deviceName = lib.mkOption {
      type = lib.types.str;
      default = if config.networking.hostName != "" then config.networking.hostName else "";
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
    listeningPort = lib.mkOption {
      default = 5555;
      type = lib.types.port;
    };
    syncPath = lib.mkOption { type = lib.types.str; };
    storagePath = lib.mkOption {
      default = "/var/lib/resilio-sync";
      type = lib.types.path;
    };
    readWriteDirs = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.str;
    };
    secrets = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          readWrite = lib.mkOption {
            default = null;
            type = lib.types.nullOr (lib.types.strMatching "^[0-9A-Z]{33}$");
          };
          encrypted = lib.mkOption { type = lib.types.strMatching "^[0-9A-Z]{33}$"; };
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
        assertion = cfg.deviceName != "";
        message = "Device name cannot be empty";
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
        assertion = secrets == lib.lists.unique secrets;
        message = "Every secret in secrets must be unique";
      }
      {
        assertion = lib.length (lib.filter (readWriteDir: cfg.secrets.${readWriteDir}.readWrite == null) cfg.readWriteDirs) == 0;
        message = "All decrypted dirs need to have a readWrite secret";
      }
    ];

    users = lib.mkIf (!cfg.webUI.enable) {
      users.rslsync = {
        isSystemUser = true;
        group = "rslsync";
        uid = config.ids.uids.rslsync;
        createHome = true;
        home = cfg.storagePath;
      };

      groups.rslsync.gid = config.ids.gids.rslsync;
    };

    system.activationScripts.resilio = lib.mkIf (!cfg.webUI.enable) ''
      mkdir -pm 0775 "${cfg.storagePath}"
      chown rslsync:rslsync "${cfg.storagePath}"

      mkdir -pm 0775 "${cfg.syncPath}"
      chown rslsync:rslsync "${cfg.syncPath}"

      find ${cfg.syncPath} -mindepth 1 -maxdepth 1 -type d ${
        lib.concatStringsSep " -and "
        (map (sharedFolder: ''-not -name "${lib.replaceStrings [ "${cfg.syncPath}/" ] [ "" ] sharedFolder.dir}"'') sharedFolders)
      } | xargs rm -rf
    '';

    systemd = let script = "${pkgs.resilio-sync}/bin/rslsync --config ${configFile} --nodaemon";
    in if cfg.webUI.enable then {
      # TODO this will cause issues if there are more than one user
      user.services.resilio = {
        description = "Resilio Sync";

        after = [ "network.target" ];
        wantedBy = [ "default.target" ];

        preStart = ''${pkgs.coreutils}/bin/mkdir -p "${cfg.syncPath}" "${cfg.storagePath}"'';
        inherit script;

        serviceConfig = {
          Type = "simple";
          StandardOutput = "null";
          StandardError = "null";
          Restart = "on-abort";
        };

        unitConfig.ConditionPathExists = [ cfg.syncPath ];
      };
    } else {
      services.resilio = lib.mkIf (!cfg.webUI.enable) {
        description = "Resilio Sync";

        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        preStart =
          "${pkgs.coreutils}/bin/mkdir -pm 0775 ${lib.concatStringsSep " " (map (sharedFolder: ''"${sharedFolder.dir}"'') sharedFolders)}";
        inherit script;

        serviceConfig = {
          StandardOutput = "null";
          StandardError = "null";
          Restart = "on-abort";

          UMask = "0002";
          User = "rslsync";
          Group = "rslsync";
        };

        unitConfig.ConditionPathExists = [ cfg.syncPath ];
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf (!cfg.webUI.enable) [ cfg.listeningPort ];
  };
}
