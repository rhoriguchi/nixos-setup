{ pkgs, nixpkgs, ... }: {
  system.stateVersion = "23.05";

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    nixPath = [ "nixpkgs=${nixpkgs}" ];
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
