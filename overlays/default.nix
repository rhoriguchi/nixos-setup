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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=355011
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "0dff4975e883f6e18d0e8adf4eab295c33200c0a";
          sha256 = "sha256-bRaTBORcCcu3gpEEGJgLawmuk/hXG0nzfOD2glRaiY4=";
        }
      }/pkgs/servers/adguardhome") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=357219
    mission-center = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "dd78a15b79aa3f741d16deadf209f6074938af82";
          sha256 = "sha256-ehZvXwABl3rdLspF4onwwsHHvrwDA4GMQSiq9lFWIaU=";
        }
      }/pkgs/by-name/mi/mission-center/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=357362
    prowlarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "e65ba64c2920d4cc69b5af1cbfa211149948e711";
          sha256 = "sha256-+xVnB8BUDgp8GAZfphvny2Y0c5qw+td6W8WqVhtJcQE=";
        }
      }/pkgs/servers/prowlarr") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=357555
    libreoffice-fresh = let
      src = super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "4a79221efa1f1a4c8cf08b25107328f2b994c517";
        sha256 = "sha256-GmOROBqOgNWoem1DvclxPflFE+R+1jrHbae3QOacYj0=";
      };
    in super.callPackage (import "${src}/pkgs/applications/office/libreoffice/wrapper.nix") {
      unwrapped = super.callPackage (import "${src}/pkgs//applications/office/libreoffice") { variant = "fresh"; };
    };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=358983
    tautulli = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "0706f4f5390fcddc62d8cf974857901a7ebf95e3";
          sha256 = "sha256-Rg6B6b4/2Ydfi6w67RWPmEeC9u6E+zon2Idg9wO184Q=";
        }
      }/pkgs/servers/tautulli") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=359151
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "414adcabe0e4c032f64737bf8d0bc079d8236ce8";
          sha256 = "sha256-HshRHzDiyd3+uYbzLTh4M1w5Qi0YoaG5mTMUrEnPrrc=";
        }
      }/pkgs/servers/plex/raw.nix") { };
  })
  (_: super: {
    discord = super.callPackage ./discord.nix { inherit (super) discord; };

    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };

    hs = super.callPackage ./hs { };
  })
]
