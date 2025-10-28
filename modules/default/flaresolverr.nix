{
  config,
  lib,
  modulesPath,
  ...
}:
let
  cfg = config.services.flaresolverr;
in
{
  # TODO switch to nix package and module once no more broken

  disabledModules = [ "${modulesPath}/services/misc/flaresolverr.nix" ];

  options.services.flaresolverr = {
    enable = lib.mkEnableOption "FlareSolverr";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8191;
    };
    prometheusExporter = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          port = lib.mkOption {
            type = lib.types.port;
            default = 8192;
          };
        };
      };
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    # https://hub.docker.com/r/flaresolverr/flaresolverr
    virtualisation.oci-containers.containers.flaresolverr = {
      image = "flaresolverr/flaresolverr:v3.4.3";

      ports = [
        "127.0.0.1:${toString cfg.port}:8191"
      ]
      ++ lib.optional cfg.prometheusExporter.enable "127.0.0.1:${toString cfg.prometheusExporter.port}:8192";

      environment = {
        TZ = config.time.timeZone;
      }
      // lib.optionalAttrs cfg.prometheusExporter.enable { PROMETHEUS_ENABLED = "true"; };
    };
  };
}
