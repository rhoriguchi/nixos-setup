[
  (_: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=185611
    fancy-motd = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "e153ea34065a3c9108c8878a7d57a5d148ca7f19";
          sha256 = "sha256-LmZbmbuYt6SOclXj7VkEMzRQQsObyZYj/nx10AT55BM=";
        }
      }/pkgs/tools/system/fancy-motd") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=199065
    resilio-sync = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "23669ce100c940d250e73ae3eb1a1c73bbbb056f";
          sha256 = "sha256-ATtIqwX+ojQg8YWkniEjZ8ITswdAmZyHNHq/RUeAcuc=";
        }
      }/pkgs/applications/networking/resilio-sync") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=199297
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "9a7cdc74a3d4c001f887ad732353002f3fbb71ec";
          sha256 = "sha256-oGRd/mvktoyM9zjNmalFrFfsVcmxFDWqLnL6Z35vv1M=";
        }
      }/pkgs/servers/adguardhome") { };
  })
  (_: super: {
    discord = super.callPackage ./discord.nix { inherit (super) discord; };

    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };

    glances = super.callPackage ./glances.nix { inherit (super) glances; };

    hs = super.callPackage ./hs { };

    solaar = super.callPackage ./solaar.nix { inherit (super) solaar; };

    tv_time_export = super.callPackage ./tv_time_export.nix { };
  })
]
