{ lib, config, pkgs, ... }:
with lib; {
  imports = [ ./secrets.nix ./services ];

  boot.loader.grub.device = "/dev/sda";

  console.keyMap = "de_CH-latin1";

  time.timeZone = "Europe/Zurich";

  nixpkgs = {
    config.allowUnfree = true;
    overlays = import ./pkgs;
  };

  system.stateVersion = "20.09";

  networking.interfaces = {
    eth0.useDHCP = true;
    wlan0.useDHCP = true;
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

    zsh = {
      enable = true;

      shellAliases = {
        l = null;
        ll = null;
        run-help = null;

        cls = "clear";
        ls = "ls --color=tty -Ah";
      };
    };
  };

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;

    users = {
      root = {
        hashedPassword = "*";
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGCgZ0lbfQGzGvXu2nkxD1wp05Kf0fTxNoiHf47g6Ii0ofY3dtG5DGHAB7gjdS2csoQ20S+5GpI0Zu2kRUIjj1XQtKGsgiDVF8fmbDOowmcrx00+Oi37/3ea2oIddBu5gD8rSiLvE0pxksqZC4iQ6FKx+8lECQo46ws/r/EUq+yiTV16FoY/CjCrYLpOkT1Oaj0K/8ZrwcWWhUfGApdvR3AudxEVB0FkmKWxJ7EkkrgUIWkijFghiPDlWpJ4n1dZIo4g5wqkGvT6Ugn0CHlbpKLxuxUWkJL7DEDcCf2xhdL8dnyp0PtzKIQA9yQYORk3AIbCWtXOOymNq2Ep2yPEAxjPYwx0tp/eX7PFLKQXas2D1GrWpPkr3t5j/61GgAQOWjhUbrTeoy8QvFcxTDezuuaIJh43rsdPafMRcCn47QyCX0XuRyIUE49IXp48XXpchV+a7o8Yoh29l8wXZnv4iAAhbpXzS+jwxReTu5useg77ZrtdmBBAlk5xGDD21ByLfW4IGFW662Tms7YJHx2ppCVJF/9py6GJ5dTkYPAbqA7eo0JmhCR45+KYR9nHasf5/Mg/g4WKUxK6NhQ19eXtgmV66REzP3PTNENyQ+pu+/jbBM8u7rVXH2GzzjfMT8kjoOsbtPJ4KIgnbpSw1LFzhYMlSf/kYCDRhCINf7swwaKQ== rhoriguchi"
        ];
      };
    };
  };

  environment = {
    etc."docker/daemon.json" = {
      enable = config.virtualisation.docker.enable;

      source = (pkgs.formats.json { }).generate "daemon.json" {
        log-driver = "json-file";
        log-opts = {
          max-file = 10;
          max-size = "10m";
        };
      };
    };

    shellAliases = {
      l = null;
      ll = null;
      run-help = null;
      which-command = null;

      cls = "clear";
      ls = "ls --color=tty -Ah";
    };
  };
}
