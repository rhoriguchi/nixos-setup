{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.borg-exporter;
in
{
  options.services.borg-exporter = {
    enable = lib.mkEnableOption "borg-exporter";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9884;
    };
    repository = lib.mkOption { type = lib.types.path; };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.borg-exporter = {
      image = "k0ral/borg-exporter:latest";

      imageFile = pkgs.borg-exporter-image;

      ports = [ "127.0.0.1:${toString cfg.port}:9884" ];

      cmd = [
        "borg-exporter"
        "--repository"
        "/repository"
      ];

      volumes = [ "${cfg.repository}:/repository" ];

      environment = {
        BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "yes";

        TZ = config.time.timeZone;
      };
    };
  };
}
