[
  (self: super: {
    firefox-addons = let nur = import (fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { pkgs = super; };
    in nur.repos.rycee.firefox-addons;

    mach-nix = import (super.fetchFromGitHub {
      owner = "DavHau";
      repo = "mach-nix";
      rev = "3.3.0";
      sha256 = "105d6b6kgvn8kll639vx5adh5hp4gjcl4bs9rjzzyqz7367wbxj6";
    }) { pkgs = super; };

    nixops = (import (super.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixops";
      rev = "45256745cef246dabe1ae8a7d109988f190cd7ef";
      sha256 = "0ni1v8ppg5cf35gq7nzd50kajxzp5zkbzhf022in0fgbjcprlzr2";
    })).default;
  })
  (self: super: {
    discord = super.callPackage ./discord.nix { inherit (super) discord; };
    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };
    glances = super.callPackage ./glances.nix { inherit (super) glances; };
    hs = super.callPackage ./hs { };
    plexPlugins = super.callPackage ./plexPlugins { };
    tv_time_export = super.callPackage ./tv_time_export.nix { };

    # TODO temp fix till resolved or never version released https://github.com/NixOS/nixpkgs/issues/96633
    # TODO upgrade to latest version
    teamviewer = super.callPackage ./teamviewer.nix { inherit (super) teamviewer; };

    # TODO temp fix till merged https://github.com/NixOS/nixpkgs/pull/124026
    adguardhome = super.adguardhome.overrideAttrs (old: {
      src = super.fetchurl {
        url = "https://github.com/AdguardTeam/AdGuardHome/releases/download/v${old.version}/AdGuardHome_linux_arm64.tar.gz";
        sha256 = "1k8bmarxh1pdj9ywlpkrm9sb704r2dsrzfybn2b6lyjyvj85x637";
      };
    });

    # TODO temp fix till merged https://github.com/dylanaraps/neofetch/pull/1873 and part of nixpkgs
    neofetch = super.callPackage ./neofetch.nix { inherit (super) neofetch; };
  })

  # TODO add hook to set 'NoDisplay=true'
  # gnome.gnome-logs # org.gnome.Logs.desktop
  # xterm # xterm.desktop
  # hplip # hplip.desktop
  # nvidia-settings # nvidia-settings.desktop
  #
  # not sure overwriting libreoffice works for libreoffice-fresh
  # libreoffice # startcenter.desktop base.desktop draw.desktop math.desktop
]
