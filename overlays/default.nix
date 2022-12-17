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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=204805
    onedrive = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "6a5deafce97258e69c922fd27dabeeb7e52fd957";
          sha256 = "sha256-cawlG1XR37aHdCt1r4xKeuMYiYlqLz8V3kw1k6kxGEE=";
        }
      }/pkgs/applications/networking/sync/onedrive") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=206049
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "6601875eab31f5defd2a476b135536827f9a210e";
          sha256 = "sha256-sede2igX/mvFS3KCJLnXZoXh0/s6OQL61aDlXSmY5f4=";
        }
      }/pkgs/servers/plex/raw.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=206424
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "7c4f2bbb2be3ab62e33c89051c5fba3c463918ac";
          sha256 = "sha256-SLkgLAdkpG5xP9dV8wDadnKbN6XJwAcRnhUyUgKVgxc=";
        }
      }/pkgs/servers/adguardhome") { };
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
