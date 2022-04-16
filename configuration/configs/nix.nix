{ pkgs, ... }: {
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.auto-optimise-store = true;
  };

  documentation.doc.enable = false;

  nixpkgs = {
    config.allowUnfree = true;
    overlays = import ../overlays;
  };

  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
}
