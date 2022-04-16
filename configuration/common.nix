{ lib, config, pkgs, ... }: {
  imports = [
    ./modules

    ./configs/i18n.nix
    ./configs/keyboard.nix
    ./configs/nano.nix
  ];

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_5_17;

  nixpkgs = {
    config.allowUnfree = true;
    overlays = import ./overlays;
  };

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.auto-optimise-store = true;
  };

  system.stateVersion = "22.05";

  hardware.enableRedistributableFirmware = true;

  networking.useDHCP = false;

  documentation.doc.enable = false;

  time.timeZone = "Europe/Zurich";

  services.openssh = {
    enable = true;

    kbdInteractiveAuthentication = false;
    passwordAuthentication = false;
  };

  programs.zsh.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;

    users.root = {
      hashedPassword = "*";
      openssh.authorizedKeys.keys = import ./authorized-keys.nix;
    };
  };

  environment = {
    variables.NIXPKGS_ALLOW_UNFREE = "1";

    shellAliases = {
      l = null;
      ll = null;
    };
  };
}
