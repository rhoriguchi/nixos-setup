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
          rev = "21fed6a80f29fe8f6adcff196fe74f2410899d35";
          hash = "sha256-CnfRn/EmguAzN7SaPhcyWeJtRoNrcHdSAqOJJGUJMmM=";
        }
      }/pkgs/tools/system/netdata") {
        inherit (super.darwin.apple_sdk.frameworks) CoreFoundation IOKit;
        protobuf = super.protobuf_21;
      };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=333966
    bazecor = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "f190f6e4881546c6c07ecad8d27b34328fbee988";
          hash = "sha256-b4eMtWeRkO5K4geEHyRNZcTdDFNpVLNRfXyKYbo8ty4=";
        }
      }/pkgs/by-name/ba/bazecor/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=334014
    tautulli = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "6f4222161156c89eb3bafc3cde32ea577fcafb72";
          sha256 = "sha256-8ZzxPfOKBQYC6rwc/YnHO0lFtwWecQV2q4NEwYoaKFs=";
        }
      }/pkgs/servers/tautulli") { };
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
