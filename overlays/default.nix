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
          rev = "a987a20ea01a7b9bea6704a6601008029945059b";
          hash = "sha256-c2lAsinKseGVncDY6l62vDTP2I5khRhKsjbAeJHcuK4=";
        }
      }/pkgs/tools/system/netdata") {
        inherit (super.darwin.apple_sdk.frameworks) CoreFoundation IOKit;
        protobuf = super.protobuf_21;
      };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=319679
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "09509747e46b8fa697f616de65ba142e95f83d2d";
          sha256 = "sha256-s8788+KHOoRYPYTPcTo+8kFgsa3ZzWElCUMh82sqL9U=";
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
