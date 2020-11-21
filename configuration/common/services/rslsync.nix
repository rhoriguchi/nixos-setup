{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.rslsync;

  isUniqueIgnoreNullByAttrName = list: attrName:
    lists.unique (builtins.filter (match: match != null)
      (map (builtins.getAttr attrName) list))
    == builtins.filter (match: match != null)
    (map (builtins.getAttr attrName) list);

  sharedFolders = map (secret: {
    secret = secret.secret;
    dir = "${cfg.syncPath}/${
        if secret.dirName != null then
          secret.dirName
        else
          builtins.hashString "sha256" secret.secret
      }";
    use_relay_server = true;
    search_lan = true;
    use_sync_trash = false;
    overwrite_changes = true;
    selective_sync = false;
    known_hosts = [ ];
  }) cfg.secrets;

  configFile = (pkgs.formats.json { }).generate "config.json" ({
    device_name = strings.toUpper cfg.deviceName;
    listening_port = cfg.listeningPort;
    storage_path = cfg.syncPath;
    check_for_updates = cfg.checkForUpdates;
    use_upnp = true;
    download_limit = 0;
    upload_limit = 0;
    directory_root = cfg.syncPath;
    directory_root_policy = "belowroot";
    send_statistics = false;
    peer_expiration_days = 1;
    use_gui = false;
    disk_low_priority = true;
  } // optionalAttrs (!cfg.webUI.enable && sharedFolders != [ ]) {
    shared_folders = sharedFolders;
  } // optionalAttrs cfg.webUI.enable {
    webui = {
      login = cfg.webUI.username;
      password = cfg.webUI.password;
      listen = "0.0.0.0:${toString cfg.webUI.port}";
    };
  });
in {
  options.rslsync = {
    enable = mkEnableOption "Resilio Sync";
    deviceName = mkOption {
      type = types.str;
      default = if config.networking.hostName != "" then
        config.networking.hostName
      else
        "";
    };
    webUI = mkOption {
      type = types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = false;
          };
          username = mkOption {
            type = types.str;
            default = "admin";
          };
          password = mkOption { type = types.str; };
          port = mkOption {
            type = types.port;
            default = 8888;
          };
        };
      };
    };
    checkForUpdates = mkOption {
      default = true;
      type = types.bool;
    };
    listeningPort = mkOption {
      default = 5555;
      type = types.port;
    };
    syncPath = mkOption { type = types.str; };
    secrets = mkOption {
      default = [ ];
      type = types.listOf (types.submodule {
        options = {
          secret = mkOption {
            type = types.str // {
              check = x: (builtins.isList (builtins.match "^[0-9A-Z]{33}$" x));
            };
          };
          dirName = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
        };
      });
    };
  };

  config = mkIf cfg.enable {
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
        assertion = cfg.webUI.enable && cfg.webUI.username != "";
        message = "When web ui is enabled username must be set";
      }
      {
        assertion = cfg.webUI.enable && cfg.webUI.password != "";
        message = "When web ui is enabled password must be set";
      }
      {
        assertion = !cfg.webUI.enable || cfg.secrets != [ ];
        message = "Secrets cannot be empty";
      }
      {
        assertion = isUniqueIgnoreNullByAttrName cfg.secrets "secret";
        message = "Secret in secrets must be unique";
      }
      {
        assertion = isUniqueIgnoreNullByAttrName cfg.secrets "dirName";
        message = "Dir name in secrets must be unique";
      }
    ];

    users = {
      users.rslsync = {
        isSystemUser = true;
        group = "rslsync";
        uid = config.ids.uids.rslsync;
      };

      groups.rslsync.gid = config.ids.gids.rslsync;
    };

    system.userActivationScripts.rslsync = ''
      ${pkgs.coreutils}/bin/mkdir -p ${cfg.syncPath}
      ${pkgs.coreutils}/bin/chown -R ${toString config.ids.uids.rslsync}:${
        toString config.ids.gids.rslsync
      } ${cfg.syncPath}
      ${pkgs.coreutils}/bin/chmod -R 0755 ${cfg.syncPath}/..
    '';

    systemd.services.rslsync = {
      after = [ "network.target" ];
      description = "Resilio Sync";
      serviceConfig = {
        ExecStart =
          "${pkgs.resilio-sync}/bin/rslsync --config ${configFile} --nodaemon";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p "
          + builtins.concatStringsSep " "
          (map (builtins.getAttr "dir") sharedFolders);
        Restart = "on-abort";
        UMask = "0007";
        User = "rslsync";
      };
      unitConfig.ConditionPathExists = [ cfg.syncPath ];
      wantedBy = [ "multi-user.target" ];
    };

    networking.firewall.allowedTCPPorts = [ cfg.listeningPort ];
  };
}
