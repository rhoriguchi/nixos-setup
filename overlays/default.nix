[
  (self: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=185611
    fancy-motd = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "e153ea34065a3c9108c8878a7d57a5d148ca7f19";
          sha256 = "sha256-LmZbmbuYt6SOclXj7VkEMzRQQsObyZYj/nx10AT55BM=";
        }
      }/pkgs/tools/system/fancy-motd") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=190397
    gitkraken = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "27a0edfd6065e8421dd390071d956b2ce76903ef";
          sha256 = "sha256-ZQmcblr5LqSFigX+4aOWV6L+MLLEAbvRAk0pxB0BLig=";
        }
      }/pkgs/applications/version-management/gitkraken") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=182618
    gnomeExtensions = super.gnomeExtensions // {
      dash-to-dock = super.gnomeExtensions.dash-to-dock.overrideAttrs (_: rec {
        version = "74";

        src = super.fetchFromGitHub {
          owner = "micheleg";
          repo = "dash-to-dock";
          rev = "extensions.gnome.org-v${version}";
          sha256 = "sha256-3WNm9kX76+qmn9KWLSKwxmHHpc21kWHrBW9266TOKZ0=";
        };
      });
    };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=193963
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "67a07358810d4ee3f45604954e14035f32ac23e7";
          sha256 = "sha256-Nm67nEKyWE4gQDJMOStFPEdqTKNyL8BsXjL1et/H1SQ=";
        }
      }/pkgs/servers/plex/raw.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=194505
    postman = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "d71a0b97b18a86afc937e9e3860cef73ca019b2f";
          sha256 = "sha256-YfgUaMM7WdXCRI8NjTdVCouS3GNbDh1Vf9sU9m5YksA=";
        }
      }/pkgs/development/web/postman") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=194935
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "21493f9c16f32e13c16579cde2b80fe2c3cbc4c9";
          sha256 = "sha256-oTrRuEGYbWzgyZ/A3RBf4NMddy/MSgo4vJo9+8LEeks=";
        }
      }/pkgs/servers/adguardhome") { };
  })
  (self: super: {
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
