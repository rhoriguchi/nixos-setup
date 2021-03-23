{ lib, config, pkgs, ... }: {
  imports = [ ./channels ./secrets.nix ./services ];

  nixpkgs = {
    config.allowUnfree = true;
    overlays = import ./overlays;
  };

  nix.autoOptimiseStore = true;

  system.stateVersion = "20.09";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

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

    users.root.hashedPassword = "*";
  };

  environment.shellAliases = {
    l = null;
    ll = null;

    cls = "clear";
    ls = "ls --color=tty -Ah";
  };
}
