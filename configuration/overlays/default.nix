# TODO restructure
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
    # TODO remove once merged https://github.com/NixOS/nixpkgs/pull/142527
    displaylink = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "b510dad7a898dcf0066b6907d4b51bbbae8baf91";
          sha256 = "0pmwf1rj41d3h7gblcjbc77rq4pjfmv176lhhsx3mkcarxjbpqzx";
        }
      }/pkgs/os-specific/linux/displaylink/default.nix") { inherit (super.linuxPackages) evdi; };
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
