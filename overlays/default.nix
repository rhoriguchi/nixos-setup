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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=333966
    bazecor = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "f190f6e4881546c6c07ecad8d27b34328fbee988";
          hash = "sha256-b4eMtWeRkO5K4geEHyRNZcTdDFNpVLNRfXyKYbo8ty4=";
        }
      }/pkgs/by-name/ba/bazecor/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=334020
    prowlarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "a7f6a89fc067551f2d6f752dd7c540e3680020cd";
          sha256 = "sha256-Yj5h67bN4TC+PTTs///5pBniIspJn5EaYTas7io3fWU=";
        }
      }/pkgs/servers/prowlarr") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=336419
    netdata = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "f07e57efe6b5fa231d872328cf0b6ba43c006a5f";
          hash = "sha256-f7dOw2c05rF57hKNhWjPJYobo4Gr50lcPzDNoy+xQbc=";
        }
      }/pkgs/tools/system/netdata") {
        inherit (super.darwin.apple_sdk.frameworks) CoreFoundation IOKit;
        protobuf = super.protobuf_21;
      };
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
