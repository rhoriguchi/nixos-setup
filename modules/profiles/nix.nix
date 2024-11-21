{ pkgs, ... }: {
  system.stateVersion = "25.05";

  nix = {
    package = pkgs.nixVersions.latest;

    channel.enable = false;

    settings = {
      nix-path = [ "nixpkgs=${pkgs.path}" ];
      trusted-users = [ "@wheel" "root" ];
      auto-optimise-store = true;
      warn-dirty = false;
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  documentation = {
    doc.enable = false;
    nixos.enable = false;
    info.enable = false;
  };

  hardware.enableRedistributableFirmware = true;

  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
}
