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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=207334
    tautulli = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "0adbfe53763f70b1ae34d65ceaef1076a689ac45";
          sha256 = "sha256-H4DEnDxyNGz5gCnyHHebr9pc7W1RwG3VZJx0WJw7FZE=";
        }
      }/pkgs/servers/tautulli") { };

    # TODO remove when fixed https://github.com/nix-community/home-manager/issues/3507
    vscode = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "3c603ddf321480716ced0b084f1132e63ea7f405";
          sha256 = "sha256-4nvaY+iIrvIBiVEPWV+k8jTsgC+dD0sHIDVcNRO5M0w=";
        }
      }/pkgs/applications/editors/vscode/vscode.nix") { };

    # TODO remove once fixed
    gitkraken = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "27a0edfd6065e8421dd390071d956b2ce76903ef";
          sha256 = "sha256-ZQmcblr5LqSFigX+4aOWV6L+MLLEAbvRAk0pxB0BLig=";
        }
      }/pkgs/applications/version-management/gitkraken") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=208661
    prowlarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "ede86a554ab3066e6a884f093c26b4db38e583a2";
          sha256 = "sha256-RJt/6/+z00Lx2mLwg+Afplv6cy2eP69ihVp0iWZe7ZY=";
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

    py-kms = super.callPackage ./py-kms.nix { };

    solaar = super.callPackage ./solaar.nix { inherit (super) solaar; };

    tv_time_export = super.callPackage ./tv_time_export.nix { };
  })
]
