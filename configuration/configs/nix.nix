{ pkgs, ... }: {
  system.stateVersion = "22.11";

  nix = {
    package = pkgs.nixUnstable;
    settings.auto-optimise-store = true;
  };

  nixpkgs.config.allowUnfree = true;

  documentation = {
    doc.enable = false;
    nixos.enable = false;
  };

  hardware.enableRedistributableFirmware = true;

  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
}
