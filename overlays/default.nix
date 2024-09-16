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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=342270
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "83c2ffcf9b74617632914f9debf3e02e9943ac53";
          sha256 = "sha256-hrYizdLhaDXKSgJ9do76xvQS694bZ39ENcMaUeALQkE=";
        }
      }/pkgs/servers/plex/raw.nix") { };

    vscode-extensions = super.vscode-extensions // {
      ms-python = super.vscode-extensions.ms-python // {
        # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=341661
        python = super.callPackage (import "${
            super.fetchFromGitHub {
              owner = "NixOS";
              repo = "nixpkgs";
              rev = "64e0dfab58293a5e33343090c2881aee766c02df";
              sha256 = "sha256-Cp6qi33k+fPttniQs82QF4izbahBMDS/1w8EwvDGGX4=";
            }
          }/pkgs/applications/editors/vscode/extensions/ms-python.python") { };
      };
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
