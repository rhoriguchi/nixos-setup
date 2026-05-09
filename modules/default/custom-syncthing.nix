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
    user = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "syncthing";
    };
    group = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "syncthing";
    };
    syncDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/syncthing";
    };
    webUI = lib.mkOption {
      type = lib.types.submodule {
        options = {
          username = lib.mkOption {
            type = lib.types.nonEmptyStr;
            default = "admin";
          };
          password = lib.mkOption {
            type = lib.types.nullOr lib.types.nonEmptyStr;
            default = null;
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
            url = lib.mkOption {
              type = lib.types.nonEmptyStr;
            };
            id = lib.mkOption {
              type = lib.types.nonEmptyStr;
            };
            token = lib.mkOption {
              type = lib.types.nonEmptyStr;
            };
          };
        }
      );
      default = { };
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
      {
        assertion = cfg.webUI.password != null;
        message = "Web ui password can't be null";
      }
    ];

    systemd.tmpfiles.rules = lib.optionals cfg.trusted [
      "d /run/syncthing 0750 ${cfg.user} ${cfg.group}"
      "L+ /run/syncthing/encryption-password - - - - ${pkgs.writeText "encryption-password" cfg.encryptionPassword}"
    ];

    services.syncthing = {
      enable = true;

      openDefaultPorts = true;

      inherit (cfg)
        key
        cert
        user
        group
        ;

      dataDir = cfg.syncDir;
      configDir = "/var/lib/syncthing/.config/syncthing";

      settings = {
        gui = {
          user = cfg.webUI.username;
          password = cfg.webUI.password;
        };

        options = {
          listenAddresses = [
            "tcp://0.0.0.0:22000"
            "quic://0.0.0.0:22000"
            "dynamic"
          ]
          ++ lib.optional (
            cfg.relay != { }
          ) "relay://${cfg.relay.url}:22067?id=${cfg.relay.id}&token=${cfg.relay.token}";

          urAccepted = -1;
          crashReportingEnabled = false;
        };

        devices = lib.mapAttrs (key: value: {
          inherit (value) id;

          addresses = [
            "tcp://${tailscaleIps.${key}}:22000"
            "quic://${tailscaleIps.${key}}:22000"
            "dynamic"
          ];

          autoAcceptFolders = false;
          untrusted = !value.trusted;
        }) cfg.devices;

        folders = lib.listToAttrs (
          map (
            folder:
            lib.nameValuePair folder (
              {
                id = builtins.hashString "sha256" folder;
                path = "${cfg.syncDir}/${if cfg.trusted then folder else builtins.hashString "sha256" folder}";

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

                ignorePerms = true;

                # A pattern beginning with a (?d) prefix enables removal of these files if they are preventing directory
                # deletion. This prefix should be used by any OS generated files which you are happy to be removed.
                ignorePatterns = map (ignore: "(?d)${ignore}") [
                  # Linux / Unix
                  "lost+found/"
                  ".Trash-*/"
                  ".nfs*"
                  ".directory"

                  # macOS
                  ".DS_Store"
                  ".AppleDouble"
                  ".LSOverride"
                  ".DocumentRevisions-V100/"
                  ".Spotlight-V100/"
                  ".TemporaryItems/"
                  ".Trashes/"
                  ".fseventsd/"
                  ".apdisk"
                  "Icon?"

                  # Windows
                  "$RECYCLE.BIN/"
                  "System Volume Information/"
                  "Desktop.ini"
                  "Thumbs.db"
                  "ehthumbs.db"
                ];
              }
              // lib.optionalAttrs cfg.trusted {
                label = folder;
              }
              // lib.optionalAttrs cfg.trashcan.enable {
                versioning = {
                  type = "trashcan";
                  cleanupIntervalS = 60 * 60;
                  params.cleanoutDays = "30";
                };
              }
            )
          ) cfg.folders
        );
      };
    };
  };
}
