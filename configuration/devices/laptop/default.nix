{ config, pkgs, lib, ... }:
with lib; {
  imports = [
    # TODO done use package source, get from github directly
    <home-manager/nixos>

    # (import "${
    #     builtins.fetchGit {
    #       ref = "release-${config.system.stateVersion}";
    #       url = "https://github.com/rycee/home-manager";
    #     }
    #   }/nixos")

    # (import "${
    #     pkgs.fetchFromGitHub {
    #       owner = "nix-community";
    #       rev = "release-${config.system.stateVersion}";
    #       sha256 = "0iksjch94wfvyq0cgwv5wq52j0dc9cavm68wka3pahhdvjlxd3js";
    #     }
    #   }/nixos")

    # TODO needs to be generated and replaced
    ./hardware-configuration.nix

    ./rhoriguchi
    ./power-managment.nix
  ];

  virtualisation.docker.enable = true;

  networking = {
    hostName = "RYAN-LAPTOP";

    # TODO commented not tested
    # wireless = {
    #   enable = true;
    #   # TODO correct interface?
    #   interfaces = [ "wlp3s0" ];
    # };
  };

  # TODO enable nvidia gpu https://nixos.wiki/wiki/Nvidia

  # TODO enable webcam

  # TODO printer support https://search.nixos.org/options?channel=unstable&from=0&size=30&sort=relevance&query=services.printing

  # TODO get drivers for function buttons
  # https://www.digitec.ch/en/s1/product/asus-vivobook-pro-15-n580gd-e4287t-1560-full-hd-intel-core-i7-8750h-16gb-256gb-2000gb-ssd-hdd-notebo-8850945

  hardware.bluetooth.enable = true;

  fileSystems."/media/Data" = {
    device = "/dev/disk/by-uuid/8b0f2c45-5560-4503-a72c-ff354e4fdb70";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  # TODO remove stupid aliases in "/etc/bashrc"
  # alias l='ls -alh'
  # alias ll='ls -l'
  # alias ls='ls --color=tty'

  # TODO gnome default language is fucked up, login screen as example

  services = {
    xserver = {
      enable = true;

      displayManager = {
        gdm.enable = true;

        # TODO displaylink
        # sessionCommands = "${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0";
      };

      desktopManager.gnome3.enable = true;

      # TODO displaylink
      # videoDrivers = [ "displaylink" "modesetting" ];
    };

    gnome3 = {
      chrome-gnome-shell.enable = false;
      gnome-initial-setup.enable = mkForce false;
    };

    teamviewer.enable = true;
  };

  programs = {
    dconf.enable = true;

    java = {
      enable = true;
      package = pkgs.jdk14;
    };

    steam.enable = true;
  };

  environment = {
    # TODO remove xterm desktop icon
    gnome3.excludePackages = (with pkgs; [ gnome-photos ])
      ++ (with pkgs.gnome3; [
        eog
        geary
        gedit
        gnome-calendar
        gnome-characters
        gnome-clocks
        gnome-contacts
        gnome-font-viewer
        gnome-maps
        gnome-music
        gnome-screenshot
        gnome-terminal
        gnome-weather
        pkgs.gnome-connections
        seahorse
        simple-scan
        totem
        yelp
      ]);

    sessionVariables.TERMINAL = "alacritty";

    systemPackages = (with pkgs; [
      alacritty
      curl
      discord
      # displaylink # TODO does not work
      docker-compose
      etcher
      firefox
      flameshot
      gimp
      git
      git-crypt
      gitkraken
      gnupg
      google-chrome
      htop
      keepass
      libreoffice-fresh
      maven
      megasync
      neofetch
      nodejs
      openssl
      postgresql
      postman
      python3
      qbittorrent
      spotify
      terraform
      virtualbox
      vlc
      vscode
    ]) ++ (with pkgs.gnome3; [ dconf-editor networkmanager-openconnect ])
      ++ (with pkgs.gnomeExtensions; [ caffeine ])
      ++ (with pkgs.haskellPackages; [ nixfmt ]) ++ (with pkgs.jetbrains; [
        datagrip
        idea-ultimate
        pycharm-professional
        webstorm
      ]) ++ (with pkgs.nodePackages; [ npm prettier ])
      ++ (with pkgs.python38Packages; [
        flake8
        mypy
        pip
        pylint
        pytest
        pytest_xdist
      ]) ++ (with pkgs.vscode-extensions;
        [ shan.code-settings-sync ]); # TODO not installed
  };

  # TODO remove everything after this line
  ############################################################################################################################
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  users.users.rhoriguchi.password = mkForce "asdf1234";

  users.users.xxlpitu = {
    extraGroups = [ "docker" "vboxusers" "wheel" ];
    password = mkForce "asdf1234";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGCgZ0lbfQGzGvXu2nkxD1wp05Kf0fTxNoiHf47g6Ii0ofY3dtG5DGHAB7gjdS2csoQ20S+5GpI0Zu2kRUIjj1XQtKGsgiDVF8fmbDOowmcrx00+Oi37/3ea2oIddBu5gD8rSiLvE0pxksqZC4iQ6FKx+8lECQo46ws/r/EUq+yiTV16FoY/CjCrYLpOkT1Oaj0K/8ZrwcWWhUfGApdvR3AudxEVB0FkmKWxJ7EkkrgUIWkijFghiPDlWpJ4n1dZIo4g5wqkGvT6Ugn0CHlbpKLxuxUWkJL7DEDcCf2xhdL8dnyp0PtzKIQA9yQYORk3AIbCWtXOOymNq2Ep2yPEAxjPYwx0tp/eX7PFLKQXas2D1GrWpPkr3t5j/61GgAQOWjhUbrTeoy8QvFcxTDezuuaIJh43rsdPafMRcCn47QyCX0XuRyIUE49IXp48XXpchV+a7o8Yoh29l8wXZnv4iAAhbpXzS+jwxReTu5useg77ZrtdmBBAlk5xGDD21ByLfW4IGFW662Tms7YJHx2ppCVJF/9py6GJ5dTkYPAbqA7eo0JmhCR45+KYR9nHasf5/Mg/g4WKUxK6NhQ19eXtgmV66REzP3PTNENyQ+pu+/jbBM8u7rVXH2GzzjfMT8kjoOsbtPJ4KIgnbpSw1LFzhYMlSf/kYCDRhCINf7swwaKQ== rhoriguchi@RYAN-LAPTOP"
    ];
  };

  networking.interfaces.wlan0.useDHCP = mkForce false;
}
