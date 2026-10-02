{ lib, ... }:
{
  virtualisation = {
    docker.autoPrune = {
      enable = lib.mkDefault true;
      flags = lib.mkDefault [ "--all" ];
    };

    podman.autoPrune = {
      enable = lib.mkDefault true;
      flags = lib.mkDefault [ "--all" ];
    };
  };
}
