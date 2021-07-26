{ lib, config, pkgs, ... }:
let
  cfg = config.services.resilio;

  secrets = let
    secrets = lib.lists.flatten (map builtins.attrValues (builtins.attrValues cfg.secrets));
    filteredSecrets = builtins.filter (secret: secret != null) secrets;
  in lib.lists.naturalSort filteredSecrets;

  sharedFolders = builtins.attrValues (builtins.mapAttrs (key: value: {
    secret = if builtins.elem key cfg.readWriteDirs then value.readWrite else value.encrypted;
    dir = "${cfg.syncPath}/${if builtins.elem key cfg.readWriteDirs then key else builtins.hashString "sha256" key}";
    use_relay_server = true;
    search_lan = true;
    use_sync_trash = false;
    overwrite_changes = true;
    selective_sync = false;
    known_hosts = [ ];
  }) cfg.secrets);

  configFile = (pkgs.formats.json { }).generate "config.json" ({
    device_name = lib.strings.toUpper cfg.deviceName;
    listening_port = cfg.listeningPort;
    storage_path = cfg.storagePath;
    check_for_updates = cfg.webUI.enable;
    use_upnp = true;
    download_limit = 0;
    upload_limit = 0;
    directory_root = cfg.syncPath;
    send_statistics = false;
    peer_expiration_days = 1;
    use_gui = false;
    disk_low_priority = true;
  } // lib.optionalAttrs (!cfg.webUI.enable) { shared_folders = sharedFolders; } // lib.optionalAttrs cfg.webUI.enable {
    webui = {
      login = cfg.webUI.username;
      password = cfg.webUI.password;
      listen = "0.0.0.0:${toString cfg.webUI.port}";
    };
  });
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
        message = "Sync path cannot be empty.";
      }
      {
        assertion = cfg.deviceName != "";
        message = "Device name cannot be empty.";
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
        assertion = builtins.length (builtins.filter (readWriteDir: cfg.secrets."${readWriteDir}".readWrite == null) cfg.readWriteDirs)
          == 0;
        message = "All decrypted dirs need to have a readWrite secret";
      }
    ];

    users = {
      users.rslsync = {
        isSystemUser = true;
        group = "rslsync";
        uid = config.ids.uids.rslsync;
        createHome = true;
        home = cfg.storagePath;
      };

      groups.rslsync.gid = config.ids.gids.rslsync;
    };

    system.activationScripts.resilio = ''
      mkdir -pm 0775 "${cfg.syncPath}"
      chown rslsync:rslsync "${cfg.syncPath}"
    '';

    systemd.services.resilio = {
      after = [ "network.target" ];
      description = "Resilio Sync";
      serviceConfig = {
        ExecStartPre = lib.mkIf (!cfg.webUI.enable) "${pkgs.coreutils}/bin/mkdir -pm 0775 ${
            builtins.concatStringsSep " " (map (sharedFolder: ''"${sharedFolder.dir}"'') sharedFolders)
          }";
        ExecStart = "${pkgs.resilio-sync}/bin/rslsync --config ${configFile} --nodaemon";
        StandardOutput = "null";
        StandardError = "null";
        Restart = "on-abort";
        UMask = "0002";
        User = "rslsync";
      };
      unitConfig.ConditionPathExists = [ cfg.syncPath ];
      wantedBy = [ "multi-user.target" ];
    };

    networking.firewall.allowedTCPPorts = [ cfg.listeningPort ];
  };
}
