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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=233653
    glances = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "6e3500fdd0d762d2fe4bf42a307aa1b8f608fa76";
          sha256 = "sha256-giBX9hOfD/Pnz0gOwNBswIpRbumqjzfgegwHmzLXgzM=";
        }
      }/pkgs/applications/system/glances") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=XXXXXXXXXXXXX
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "3014fe9ef813ddfe184ed50289be4d707cb28ff9";
          sha256 = "sha256-zdSvL83gTM0nblN5CG7XSP/POtV9vUt7Ea40THb0VH8=";
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

    nixopsUnstable = super.nixopsUnstable.withPlugins (_: [ ]);

    hs = super.callPackage ./hs { };

    py-kms = super.callPackage ./py-kms.nix { };

    solaar = super.callPackage ./solaar.nix { inherit (super) solaar; };
  })
]
