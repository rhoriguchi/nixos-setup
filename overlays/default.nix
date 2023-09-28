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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=247828
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "d4a2d8b4cdca9b475301e33da3b1970e81e2d24a";
          sha256 = "sha256-2f6w65Z8VpNFgEZEBgHRXmhcFI3uvfCKQKmWKYcTLJ0=";
        }
      }/pkgs/servers/adguardhome") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=255954
    prowlarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "d0664154df01056c5222833be2fbd9c831d1b3a4";
          sha256 = "sha256-XTNq2qhYeuUPoMJEpH5t9gjkQ5yn41vGK9ilTokBFLw=";
        }
      }/pkgs/servers/prowlarr") { };
  })
  (_: super: {
    discord = super.callPackage ./discord.nix { inherit (super) discord; };

    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };

    glances = super.callPackage ./glances.nix { inherit (super) glances; };

    hs = super.callPackage ./hs { };

    nodePackages = super.nodePackages // super.callPackage ./node-packages { pkgs = super; };

    solaar = super.callPackage ./solaar.nix { inherit (super) solaar; };
  })
]
