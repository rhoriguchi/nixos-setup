{ pkgs, ... }: {
  system.stateVersion = "24.05";

  nix = {
    package = pkgs.nixVersions.latest;

    settings = {
      trusted-users = [ "@wheel" "root" ];
      auto-optimise-store = true;
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config.allowUnfree = true;

  documentation = {
    doc.enable = false;
    nixos.enable = false;
  };

  hardware.enableRedistributableFirmware = true;

  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
}
