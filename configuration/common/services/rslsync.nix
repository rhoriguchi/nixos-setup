{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.rslsync;

  sharedFolders = builtins.map (secret: {
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

  configFile = pkgs.writeText "config.json" (builtins.toJSON {
    device_name = lib.strings.toUpper cfg.deviceName;
    listening_port = cfg.listeningPort;
    storage_path = cfg.syncPath;
    check_for_updates = true;
    use_upnp = true;
    download_limit = 0;
    upload_limit = 0;
    directory_root = cfg.syncPath;
    directory_root_policy = "belowroot";
    shared_folders = sharedFolders;
    send_statistics = false;
    peer_expiration_days = 1;
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
    listeningPort = mkOption {
      default = 5555;
      type = types.int;
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
        assertion = builtins.length cfg.secrets > 0;
        message = "Secrets cannot be empty";
      }
      {
        # TODO use map function to get all secret and check if unique
        assertion = lib.lists.unique cfg.secrets == cfg.secrets;
        message = "Secret in secrets must be unique";
      }
      {
        # TODO use map function to get all dirName and check if unique
        assertion = lib.lists.unique cfg.secrets == cfg.secrets;
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

    systemd.services.rslsync = {
      after = [ "network.target" ];
      description = "Resilio Sync";
      serviceConfig = {
        ExecStart =
          "${pkgs.resilio-sync}/bin/rslsync --config ${configFile} --nodaemon";
        ExecStartPre = "${pkgs.busybox}/bin/mkdir -p "
          + builtins.concatStringsSep " "
          (builtins.map (builtins.getAttr "dir") sharedFolders);
        Restart = "on-abort";
        UMask = "0007";
        User = "rslsync";
      };
      wantedBy = [ "multi-user.target" ];
    };

    networking.firewall.allowedTCPPorts = [ cfg.listeningPort ];
  };
}
