{ config, lib, pkgs, ... }:
let
  cfg = config.services.gphotos-sync;

  secretFile = pkgs.writers.writeJSON "secret.json" {
    installed = {
      project_id = cfg.projectId;
      client_id = cfg.clientId;
      client_secret = cfg.clientSecret;
      auth_uri = "https://accounts.google.com/o/oauth2/auth";
      token_uri = "https://oauth2.googleapis.com/token";
      auth_provider_x509_cert_url = "https://www.googleapis.com/oauth2/v1/certs";
      redirect_uris = [ "http://127.0.0.1" "urn:ietf:wg:oauth:2.0:oob" ];
    };
  };

  args = lib.concatStringsSep " " [
    "--archived"
    "--do-delete"
    "--flush-index"
    "--omit-album-date"
    "--progress"
    "--rescan"
    "--retry-download"
    "--secret ${secretFile}"
  ];
in {
  options.services.gphotos-sync = {
    enable = lib.mkEnableOption "Google Photos Sync";
    user = lib.mkOption {
      type = lib.types.str;
      default = "gphotos-sync";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "gphotos-sync";
    };
    exportPath = lib.mkOption { type = lib.types.path; };
    projectId = lib.mkOption { type = lib.types.str; };
    clientId = lib.mkOption { type = lib.types.str; };
    clientSecret = lib.mkOption { type = lib.types.str; };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.exportPath != "";
        message = "Export path cannot be empty";
      }
      {
        assertion = cfg.projectId != "";
        message = "ProjectId cannot be empty";
      }
      {
        assertion = cfg.clientId != "";
        message = "ClientId cannot be empty";
      }
      {
        assertion = cfg.clientSecret != "";
        message = "ClientSecret cannot be empty";
      }
    ];

    users = {
      users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
      };

      groups.${cfg.group} = { };
    };

    systemd.services.gphotos-sync = {
      after = [ "network.target" ];

      preStart = ''mkdir -p "${cfg.exportPath}"'';
      script = ''${pkgs.gphotos-sync}/bin/gphotos-sync ${args} "${cfg.exportPath}"'';

      startAt = "04:00";

      serviceConfig = {
        Restart = "on-abort";
        User = cfg.user;
        Group = cfg.group;
      };
    };
  };
}
