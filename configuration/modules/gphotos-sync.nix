{ lib, config, pkgs, ... }:
let
  cfg = config.services.gphotos-sync;

  secretFile = (pkgs.formats.json { }).generate "secret.json" {
    installed = {
      project_id = cfg.projectId;
      client_id = cfg.clientId;
      client_secret = cfg.clientSecret;
      auth_uri = "https://accounts.google.com/o/oauth2/auth";
      token_uri = "https://oauth2.googleapis.com/token";
      auth_provider_x509_cert_url = "https://www.googleapis.com/oauth2/v1/certs";
      redirect_uris = [ "http://localhost" "urn:ietf:wg:oauth:2.0:oob" ];
    };
  };

  args = lib.concatStringsSep " " [
    "--archived"
    "--do-delete"
    "--flush-index"
    "--omit-album-date"
    "--rescan"
    "--retry-download"
    "--secret ${secretFile}"
  ];
in {
  options.services.gphotos-sync = {
    enable = lib.mkEnableOption "Google Photos Sync";
    exportPath = lib.mkOption { type = lib.types.str; };
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
      users.gphotos-sync = {
        isSystemUser = true;
        group = "gphotos-sync";
        extraGroups = lib.optional config.services.resilio.enable "rslsync";
      };

      groups.gphotos-sync = { };
    };

    systemd.services.gphotos-sync = {
      after = [ "network.target" ];
      description = "gphotos-sync";
      serviceConfig = {
        ExecStartPre = ''${pkgs.coreutils}/bin/mkdir -p "${cfg.exportPath}"'';
        ExecStart = ''${pkgs.gphotos-sync}/bin/gphotos-sync ${args} "${cfg.exportPath}"'';
        Restart = "on-abort";
        UMask = "0002";
        User = "gphotos-sync";
        Group = if config.services.resilio.enable then "rslsync" else "gphotos-sync";
      };
      startAt = "04:00";
    };
  };
}
