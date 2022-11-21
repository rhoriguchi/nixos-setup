[
  (_: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=185611
    fancy-motd = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "4fd5da3781ed6d12a139bee1c84d17772edf130c";
          sha256 = "sha256-VlvxAWOKZ/ih7bxKxD2qfp2S8skGABS90hfmP8aV2w0=";
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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=200223
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "15484a9f2f840f44f52997974c5101d3536d2e33";
          sha256 = "sha256-Hau6E3Cdl0QEC1W8FKmFwmz3UZEyZqHgyoURkcOTFVA=";
        }
      }/pkgs/servers/adguardhome") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=200226
    tautulli = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "ce604a83c116e6e208e5c1c59ca4486ef271a806";
          sha256 = "sha256-F2MS8HKv4nOOj+fICyLS869ljb8cluUpxEAIYjnzDOo=";
        }
      }/pkgs/servers/tautulli") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=202024
    teamviewer = super.libsForQt515.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "b9a8eae2a4068c05c253508e2063fd0d3d193311";
          sha256 = "sha256-xqlq27e8g94aWkzs8pXT7BeWznZSzdSfdUTPTWdzdY4=";
        }
      }/pkgs/applications/networking/remote/teamviewer") { };
  })
  (_: super: {
    discord = super.callPackage ./discord.nix { inherit (super) discord; };

    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };

    glances = super.callPackage ./glances.nix { inherit (super) glances; };

    hs = super.callPackage ./hs { };

    py-kms = super.callPackage ./py-kms.nix { };

    solaar = super.callPackage ./solaar.nix { inherit (super) solaar; };

    tv_time_export = super.callPackage ./tv_time_export.nix { };
  })
]
