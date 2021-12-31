{ lib, config, pkgs, ... }: {
  imports = [ ./modules ];

  nixpkgs = {
    config.allowUnfree = true;
    overlays = import ./overlays;
  };

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    autoOptimiseStore = true;
  };

  system.stateVersion = "22.05";

  networking.useDHCP = false;

  documentation.doc.enable = false;

  time.timeZone = "Europe/Zurich";

  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_COLLATE = "en_US.UTF-8";
      LC_MEASUREMENT = "de_CH.UTF-8";
      LC_MESSAGES = "en_US.UTF-8";
      LC_MONETARY = "de_CH.UTF-8";
      LC_NUMERIC = "de_CH.UTF-8";
      LC_PAPER = "de_CH.UTF-8";
      LC_TIME = "de_CH.UTF-8";
    };
  };

  services.openssh = {
    enable = true;

    challengeResponseAuthentication = false;
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
