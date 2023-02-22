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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=217306
    prowlarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "7bae9f8f6e1d74b2a19adf705d2efcc16cedd2c2";
          sha256 = "sha256-i0Xho7dWSMeGH91o0m5unV6GndulW/pWdr/7a/cXfkA=";
        }
      }/pkgs/servers/prowlarr") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=217761
    gitkraken = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "da14312c42bd6f5211afa25882322c78d3782968";

          sha256 = "sha256-8wKyABjCxs4cuDkbketj3+OjTStU5XqbcmHpO5AkHGc=";
        }
      }/pkgs/applications/version-management/gitkraken") { };
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
  })
]
