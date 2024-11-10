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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=354995
    sonarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "113f56a42130941612fe7f56246d7ff3da27dbe1";
          sha256 = "sha256-tXIK9Dz1ypI/PKDV7hJqmRLUfeZ2Rvp7ckmTf1qob3o=";
        }
      }/pkgs/by-name/so/sonarr/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=355011
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "0dff4975e883f6e18d0e8adf4eab295c33200c0a";
          sha256 = "sha256-bRaTBORcCcu3gpEEGJgLawmuk/hXG0nzfOD2glRaiY4=";
        }
      }/pkgs/servers/adguardhome") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=355016
    prowlarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "79fccb5048611847344cdc8d15f99d3b36a89cc7";
          sha256 = "sha256-wnagBi+XG6qc7M87lqs2Kk/QTMAzpUyvq8iUaeJh270=";
        }
      }/pkgs/servers/prowlarr") { };
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
