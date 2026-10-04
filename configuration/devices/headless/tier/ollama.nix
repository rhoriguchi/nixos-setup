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
      # https://ollama.com/library/gemma4:12b
      "gemma4:12b"
    ];
  };
}
