{ config, lib, ... }:
let
  # 9000 is used by mealie
  port = 9800;
  dataDir = "/var/lib/subgen";
in
{
  assertions = [
    {
      assertion = lib.elem "nvidia" config.services.xserver.videoDrivers;
      message = "Subgen requires the nvidia video driver";
    }
  ];

  hardware.nvidia-container-toolkit.enable = true;

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0755 root root"
    "d ${dataDir}/cache 0755 root root"
    "d ${dataDir}/models 0755 root root"
  ];

  # https://hub.docker.com/r/mccloud/subgen
  virtualisation.oci-containers.containers.subgen = {
    image = "docker.io/mccloud/subgen:2026.07.3";

    devices = [ "nvidia.com/gpu=all" ];

    extraOptions = [
      "--network=host"
    ];

    volumes = [
      "${dataDir}/models:/subgen/models"
      "${dataDir}/cache:/cache"
    ];

    environment = {
      TZ = config.time.timeZone;

      TRANSCRIBE_DEVICE = "cuda";
      WHISPER_MODEL = "large-v3";
      CONCURRENT_TRANSCRIPTIONS = "1";

      WEBHOOK_PORT = toString port;
      MODEL_PATH = "/subgen/models";
    };
  };
}
