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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=186139
    tautulli = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "509541c7a735db6346da0f75eda9e7870c078ecc";
          sha256 = "sha256-bfVTqsKII0DaewAUwnGnG8m4cfP+g8Sa4aDZr5myJXg=";
        }
      }/pkgs/servers/tautulli") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=190397
    gitkraken = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "27a0edfd6065e8421dd390071d956b2ce76903ef";
          sha256 = "sha256-ZQmcblr5LqSFigX+4aOWV6L+MLLEAbvRAk0pxB0BLig=";
        }
      }/pkgs/applications/version-management/gitkraken") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=191214
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "70cfa0d6ae54489e8af35032b9ef80ef43ff0952";
          sha256 = "sha256-j9DeLkebtGPkh+248wHLwjAkMpW6m7GE4gZQsz9ew/o=";
        }
      }/pkgs/servers/adguardhome") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=192920
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
