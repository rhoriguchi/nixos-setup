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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=236205
    prowlarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "8c49349c746bb9765223461025141a65d6ca0a4e";
          sha256 = "sha256-0A9Px3p1H6IUmLSbCjDzcFKDTkV1G6yansNcZObGY6E=";
        }
      }/pkgs/servers/prowlarr") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=237258
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "1f9be6a55c7ff8bc2e1f21f1ee29815053b3defc";
          sha256 = "sha256-nGcohDWUoVjamM/uXp9Kf8Ecn2REwj6+HeXPAB5LGuA=";
        }
      }/pkgs/servers/adguardhome") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=237597
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "97cc99c5afb7ab2c57cfb855efdacc6c401d6a1d";
          sha256 = "sha256-pAWAdGUzxHz0KQ7ZmwDyuYZMysU256lAvDvRjDLVQPY=";
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

    py-kms = super.callPackage ./py-kms.nix { };

    solaar = super.callPackage ./solaar.nix { inherit (super) solaar; };
  })
]
