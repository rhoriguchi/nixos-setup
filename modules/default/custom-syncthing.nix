{
  config,
  lib,
  libCustom,
  pkgs,
  ...
}:
let
  cfg = config.services.custom-syncthing;

  tailscaleIps = import (
    libCustom.relativeToRoot "configuration/devices/headless/nelliel/headscale/ips.nix"
  );
in
{
  options.services.custom-syncthing = {
    enable = lib.mkEnableOption "Custom Syncthing";
    cert = lib.mkOption {
      type = lib.types.nonEmptyStr;
    };
    key = lib.mkOption {
      type = lib.types.nonEmptyStr;
    };
    trusted = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    encryptionPassword = lib.mkOption {
      type = lib.types.nullOr lib.types.nonEmptyStr;
      default = null;
    };
    # TODO add username and password https://docs.syncthing.net/users/config.html#gui-element
    gui = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
      };
      default = { };
    };
    trashcan = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
      };
      default = { };
    };
    relay = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            id = lib.mkOption {
              type = lib.types.nullOr lib.types.nonEmptyStr;
            };
            token = lib.mkOption {
              type = lib.types.nullOr lib.types.nonEmptyStr;
            };
          };
        }
      );
      default = null;
    };
    devices = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            id = lib.mkOption {
              type = lib.types.nonEmptyStr;
            };
            trusted = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
          };
        }
      );
      default = { };
    };
    folders = lib.mkOption {
      type = lib.types.listOf lib.types.nonEmptyStr;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.trusted -> cfg.encryptionPassword != null;
        message = "When device is trusted encryptionPassword can't be null";
      }
    ];

    systemd.tmpfiles.rules = lib.optionals cfg.trusted [
      "d /run/syncthing 0750 ${config.services.syncthing.user} ${config.services.syncthing.group}"
      "L+ /run/syncthing/encryption-password - - - - ${pkgs.writeText "encryption-password" cfg.encryptionPassword}"
    ];

    services.syncthing = {
      enable = true;

      openDefaultPorts = true;

      inherit (cfg) key cert;

      settings = {
        gui.enable = cfg.gui.enable;

        options = {
          listenAddress = lib.concatStringsSep "," (
            [ "default" ]
            ++ lib.optional (
              cfg.relay != null
            ) "relay://syncthing-relay.00a.ch?id=${cfg.relay.id}&token=${cfg.relay.token}"
          );

          urAccepted = -1;
          crashReportingEnabled = false;
        };

        # TODO commented
        # defaults = {
        #   # TODO check .sync/IgnoreList
        #   # TODo move to folders?
        #   # A pattern beginning with a (?d) prefix enables removal of these files if they are preventing directory
        #   # deletion. This prefix should be used by any OS generated files which you are happy to be removed.
        #   ignores = map (ignore: "(?d)${ignore}") [
        #     ".Trash-*"
        #     ".fseventsd"
        #     ".Spotlight-V100"
        #     ".TemporaryItems"
        #     ".Trashes"
        #     "lost+found"
        #     "$RECYCLE.BIN"
        #     "$Recycle.Bin"
        #   ];
        # };

        devices = lib.mapAttrs (key: value: {
          inherit (value) id;

          addresses = [
            "tcp://${tailscaleIps.${key}}:22000"
            "dynamic"
          ];

          autoAcceptFolders = false;
          untrusted = !value.trusted;
        }) cfg.devices;

        folders = lib.listToAttrs (
          map (
            folder:
            lib.nameValuePair folder {
              id = builtins.hashString "sha256" folder;
              path = "~/${if cfg.trusted then folder else builtins.hashString "sha256" folder}";

              devices = lib.mapAttrsToList (
                key: value:
                if (cfg.trusted && !value.trusted) then
                  {
                    name = key;
                    encryptionPasswordFile = "/run/syncthing/encryption-password";
                  }
                else
                  key
              ) cfg.devices;

              type = if cfg.trusted then "sendreceive" else "receiveencrypted";
            }
            // lib.optionalAttrs cfg.trusted {
              label = folder;
            }
            // lib.optionalAttrs cfg.trashcan.enable {
              versioning = {
                type = "trashcan";
                cleanupIntervalS = 60 * 60 * 24;
                params = {
                  keep = 1;
                  cleanoutDays = 30;
                };
              };
            }
          ) cfg.folders
        );
      };
    };
  };
}
