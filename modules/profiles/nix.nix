{ pkgs, ... }: {
  system.stateVersion = "24.11";

  nix = {
    package = pkgs.nixVersions.latest;

    channel.enable = false;

    settings = {
      nix-path = [ "nixpkgs=${pkgs.path}" ];
      trusted-users = [ "@wheel" "root" ];
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  documentation = {
    doc.enable = false;
    nixos.enable = false;
  };

  hardware.enableRedistributableFirmware = true;

  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
}
