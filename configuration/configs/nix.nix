{ pkgs, ... }: {
  system.stateVersion = "22.05";

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.auto-optimise-store = true;
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = import ../overlays;
  };

  documentation.doc.enable = false;

  hardware.enableRedistributableFirmware = true;

  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
}
