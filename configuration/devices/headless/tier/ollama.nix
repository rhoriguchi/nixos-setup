{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.ollama = {
    enable = true;

    host = "0.0.0.0";

    package =
      if lib.elem "nvidia" config.services.xserver.videoDrivers then pkgs.ollama-cuda else pkgs.ollama;

    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "5m";

      OLLAMA_CONTEXT_LENGTH = "131072";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_NUM_PARALLEL = "1";
    };

    syncModels = true;
    loadModels = [
      # https://ollama.com/library/gemma4:12b
      "gemma4:12b"
    ];
  };

  networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
    config.services.ollama.port
  ];
}
