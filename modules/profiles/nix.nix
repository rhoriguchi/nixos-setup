{ pkgs, ... }: {
  system.stateVersion = "24.05";

  nix = {
    settings.trusted-users = [ "@wheel" "root" ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
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
