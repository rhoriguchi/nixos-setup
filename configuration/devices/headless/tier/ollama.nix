{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.ollama = {
    enable = true;

    package =
      if lib.elem "nvidia" config.services.xserver.videoDrivers then pkgs.ollama-cuda else pkgs.ollama;

    environmentVariables.OLLAMA_KEEP_ALIVE = "5m";

    syncModels = true;
    loadModels = [
      "qwen2.5vl:7b"
    ];
  };
}
