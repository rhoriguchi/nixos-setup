{ lib, config, pkgs, ... }:
with lib; {
  imports = [ ./secrets.nix ./services ];

  nixpkgs = {
    config.allowUnfree = true;
    overlays = import ./pkgs;
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };

  system.stateVersion = "20.09";

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

  virtualisation.docker = {
    logDriver = "json-file";
    extraOptions = builtins.concatStringsSep " " [
      "--log-opt max-file=10"
      "--log-opt max-size=10m"
    ];
  };

  environment = {
    shellAliases = {
      l = null;
      ll = null;

      cls = "clear";
      ls = "ls --color=tty -Ah";
    };

    systemPackages = with pkgs; [ glances ];
  };
}
