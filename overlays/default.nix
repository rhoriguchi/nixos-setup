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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=189875
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "4a77588c79aef32fa10cbecb77c7bad122f068e8";
          sha256 = "sha256-jDM7KM1RP81Y4qkONM9wcNN8/1vr3zXM9ylr8H1O4QA==";
        }
      }/pkgs/servers/plex/raw.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=190191
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "rhoriguchi";
          repo = "nixpkgs";
          rev = "889069b8b3433895f1a84b8f5ebb2751d867cf32";
          sha256 = "sha256-6h1ebTteIDN+XXsQXYYnfFV46Oa8keBZeN9RG0YWlGw=";
        }
      }/pkgs/servers/adguardhome") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=190258
    gnomeExtensions = super.gnomeExtensions // {
      dash-to-dock = super.gnomeExtensions.dash-to-dock.overrideAttrs (_: rec {
        version = "73";

        src = super.fetchFromGitHub {
          owner = "micheleg";
          repo = "dash-to-dock";
          rev = "extensions.gnome.org-v${version}";
          sha256 = "/NOJWjotfYPujS5G7/zv1OLzfSW0MB+oIRsx9/LSEdA=";
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
