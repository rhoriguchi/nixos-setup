{ pkgs, ... }: {
  system.stateVersion = "25.11";

  nix = {
    package = pkgs.nixVersions.latest;

    channel.enable = false;

    settings = {
      trusted-users = [ "@wheel" "root" ];
      auto-optimise-store = true;
      warn-dirty = false;
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  hardware.enableRedistributableFirmware = true;

  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
}
