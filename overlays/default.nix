[
  (self: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=181856
    gitkraken = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "e12aa0bb9e0d9392cb9d6158e2cea36611bb38a8";
          sha256 = "sha256-6AicdbFzWft4c6rCjm2XJ8KCvrnZM0/lGi8csFoSN7w=";
        }
      }/pkgs/applications/version-management/gitkraken") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=182817
    vscode-extensions = super.vscode-extensions // {
      ms-vscode.PowerShell = super.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "PowerShell";
          publisher = "ms-vscode";
          version = "2022.6.3";
          sha256 = "sha256-P8kakmpT3yAkKFroKttiLOV7PneOIoQOEtwImPIDHQY=";
        };
      };
    };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=184196
    glances = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "550f8b9ddd9821a62213523cef094c8fc0c7c355";
          sha256 = "sha256-diiqvBX/p9hlra6t80MaTNN+DajBd/ahwwx9A0GuKbs=";
        }
      }/pkgs/applications/system/glances") { };

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
