{
  config,
  lib,
  pkgs,
  ...
}:
{
  system.stateVersion = "26.05";

  nix = {
    package = pkgs.nixVersions.latest;

    channel.enable = false;

    settings = {
      trusted-users = [
        "@wheel"
        "root"
      ];
      allowed-users = [
        "@wheel"
        "root"
      ]
      ++ lib.attrNames (lib.filterAttrs (_: value: value.isNormalUser) config.users.users);
      auto-optimise-store = true;
      warn-dirty = false;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  hardware.enableRedistributableFirmware = true;

  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
}
