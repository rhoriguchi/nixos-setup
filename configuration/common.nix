{ lib, config, pkgs, ... }: {
  imports = [
    ./modules

    ./configs/i18n.nix
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

  programs = {
    nano = {
      nanorc = ''
        set constantshow
        set linenumbers
        set softwrap
        set tabsize 4
        set tabstospaces
        unset nonewlines
      '';

      syntaxHighlight = true;
    };

    zsh.enable = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;

    users.root = {
      hashedPassword = "*";
      openssh.authorizedKeys.keys = import ./authorized-keys.nix;
    };
  };

  environment = {
    variables = {
      EDITOR = "nano";
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    shellAliases = {
      l = null;
      ll = null;
    };
  };
}
