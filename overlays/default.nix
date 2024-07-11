[
  (_: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=185611
    fancy-motd = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "4fd5da3781ed6d12a139bee1c84d17772edf130c";
          hash = "sha256-VlvxAWOKZ/ih7bxKxD2qfp2S8skGABS90hfmP8aV2w0=";
        }
      }/pkgs/tools/system/fancy-motd") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=319032
    netdata = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "57eccbb4deed82851c54c18d67a1a15e3465767a";
          hash = "sha256-QVn7G9WZte4WIBNwL3p2x8OmLpP7XtfinPSadkAXZN4=";
        }
      }/pkgs/tools/system/netdata") {
        inherit (super.darwin.apple_sdk.frameworks) CoreFoundation IOKit;
        protobuf = super.protobuf_21;
      };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=325186
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "6b75aa0af800b0cc6d2a2d6aef160a77c0660240";
          sha256 = "sha256-a3TX+difrenFlc1jgeHvvXlYTQx5h3P3SF3ZXmsqHtA=";
        }
      }/pkgs/servers/adguardhome") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=326347
    bazecor = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "d98b8999b9f6af41bfc58dc333ff414c73e915c8";
          hash = "sha256-OxgESw2fvl4fXKW/Vo82Q3tGf7tGmEvvRRbtUdGe5qU=";
        }
      }/pkgs/applications/misc/bazecor") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=326379
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "196e4af886085b6525f3ff85c02010cfd0f8295c";
          sha256 = "sha256-APuaU5LPfdlXDKAE86mPSM4Wgy9sF3bxhDLMa+jUmpg=";
        }
      }/pkgs/servers/plex/raw.nix") { };
  })
  (_: super: {
    discord = super.callPackage ./discord.nix { inherit (super) discord; };

    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };

    glances = super.callPackage ./glances.nix { inherit (super) glances; };

    hs = super.callPackage ./hs { };
  })
]
