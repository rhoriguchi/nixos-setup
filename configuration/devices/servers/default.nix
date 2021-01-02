{ pkgs, lib, config, ... }:
with lib; {
  system.autoUpgrade = {
    enable = true;
    dates = "daily";
  };

  nix = {
    # TODO use this for all devices? laptop?
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };

    optimise = {
      automatic = true;
      dates = [ "daily" ];
    };
  };

  networking.networkmanager = {
    ethernet.macAddress = "permanent";
    wifi.macAddress = "permanent";
  };

  console.keyMap = "de_CH-latin1";

  services = {
    glances.enable = true;

    openssh = {
      enable = true;
      passwordAuthentication = false;
    };

    journald.extraConfig = "Storage=persistent";
  };

  environment.systemPackages = with pkgs; [ glances htop ];

  users.users = {
    root = {
      hashedPassword = "*";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGCgZ0lbfQGzGvXu2nkxD1wp05Kf0fTxNoiHf47g6Ii0ofY3dtG5DGHAB7gjdS2csoQ20S+5GpI0Zu2kRUIjj1XQtKGsgiDVF8fmbDOowmcrx00+Oi37/3ea2oIddBu5gD8rSiLvE0pxksqZC4iQ6FKx+8lECQo46ws/r/EUq+yiTV16FoY/CjCrYLpOkT1Oaj0K/8ZrwcWWhUfGApdvR3AudxEVB0FkmKWxJ7EkkrgUIWkijFghiPDlWpJ4n1dZIo4g5wqkGvT6Ugn0CHlbpKLxuxUWkJL7DEDcCf2xhdL8dnyp0PtzKIQA9yQYORk3AIbCWtXOOymNq2Ep2yPEAxjPYwx0tp/eX7PFLKQXas2D1GrWpPkr3t5j/61GgAQOWjhUbrTeoy8QvFcxTDezuuaIJh43rsdPafMRcCn47QyCX0XuRyIUE49IXp48XXpchV+a7o8Yoh29l8wXZnv4iAAhbpXzS+jwxReTu5useg77ZrtdmBBAlk5xGDD21ByLfW4IGFW662Tms7YJHx2ppCVJF/9py6GJ5dTkYPAbqA7eo0JmhCR45+KYR9nHasf5/Mg/g4WKUxK6NhQ19eXtgmV66REzP3PTNENyQ+pu+/jbBM8u7rVXH2GzzjfMT8kjoOsbtPJ4KIgnbpSw1LFzhYMlSf/kYCDRhCINf7swwaKQ== rhoriguchi"
      ];
    };

    xxlpitu = {
      extraGroups = [ "wheel" ]
        ++ optional config.virtualisation.docker.enable "docker";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGCgZ0lbfQGzGvXu2nkxD1wp05Kf0fTxNoiHf47g6Ii0ofY3dtG5DGHAB7gjdS2csoQ20S+5GpI0Zu2kRUIjj1XQtKGsgiDVF8fmbDOowmcrx00+Oi37/3ea2oIddBu5gD8rSiLvE0pxksqZC4iQ6FKx+8lECQo46ws/r/EUq+yiTV16FoY/CjCrYLpOkT1Oaj0K/8ZrwcWWhUfGApdvR3AudxEVB0FkmKWxJ7EkkrgUIWkijFghiPDlWpJ4n1dZIo4g5wqkGvT6Ugn0CHlbpKLxuxUWkJL7DEDcCf2xhdL8dnyp0PtzKIQA9yQYORk3AIbCWtXOOymNq2Ep2yPEAxjPYwx0tp/eX7PFLKQXas2D1GrWpPkr3t5j/61GgAQOWjhUbrTeoy8QvFcxTDezuuaIJh43rsdPafMRcCn47QyCX0XuRyIUE49IXp48XXpchV+a7o8Yoh29l8wXZnv4iAAhbpXzS+jwxReTu5useg77ZrtdmBBAlk5xGDD21ByLfW4IGFW662Tms7YJHx2ppCVJF/9py6GJ5dTkYPAbqA7eo0JmhCR45+KYR9nHasf5/Mg/g4WKUxK6NhQ19eXtgmV66REzP3PTNENyQ+pu+/jbBM8u7rVXH2GzzjfMT8kjoOsbtPJ4KIgnbpSw1LFzhYMlSf/kYCDRhCINf7swwaKQ== rhoriguchi"
      ];
    };
  };
}
