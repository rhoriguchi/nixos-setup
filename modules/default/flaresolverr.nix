{ config, lib, pkgs, modulesPath, ... }:
let cfg = config.services.flaresolverr;
in {
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
      image = "flaresolverr/flaresolverr:v3.3.21";

      imageFile = pkgs.dockerTools.pullImage {
        imageName = "flaresolverr/flaresolverr";
        imageDigest = "sha256:f104ee51e5124d83cf3be9b37480649355d223f7d8f9e453d0d5ef06c6e3b31b"; # linux/amd64
        sha256 = "sha256-unGzkgDG5RvVPz+cHdNqizBjEf9FCHSMwi7PbRgjETI=";

        finalImageTag = "v3.3.21";
      };

      ports = [ "127.0.0.1:${toString cfg.port}:8191" ]
        ++ lib.optional cfg.prometheusExporter.enable "127.0.0.1:${toString cfg.prometheusExporter.port}:8192";

      environment = { TZ = config.time.timeZone; } // lib.optionalAttrs cfg.prometheusExporter.enable { PROMETHEUS_ENABLED = "true"; };
    };
  };
}
