[
  (self: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=178811
    nixopsUnstable = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "ea7336a084a37d99548781ddeb4de41f394ca3f1";
          sha256 = "sha256-wa/IIm7o93DwRfKF6w5YRI3qSG9T7dxC8iNiisdJA04=";
        }
      }/pkgs/applications/networking/cluster/nixops") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=178856
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "7c0498e3cbab0825d2135d449e8800e4eb2700b9";
          sha256 = "sha256-FdKmtAgt99U0NzkEf9QfroeaQ5DGTwgONQl83TeZovY=";
        }
      }/pkgs/servers/plex/raw.nix") { };
  })
  (self: super: {
    mach-nix = import (super.fetchFromGitHub {
      owner = "DavHau";
      repo = "mach-nix";
      rev = "3.5.0";
      hash = "sha256-j/XrVVistvM+Ua+0tNFvO5z83isL+LBgmBi9XppxuKA=";
    }) { pkgs = super; };
  })
  (self: super:
    let nur = import (fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { pkgs = super; };
    in {
      discord = super.callPackage ./discord.nix { inherit (super) discord; };

      displaylink = super.callPackage ./displaylink {
        inherit (super) displaylink;
        inherit (super.linuxPackages) evdi;
      };

      firefox-addons = nur.repos.rycee.firefox-addons;

      glances = super.callPackage ./glances.nix { inherit (super) glances; };

      hs = super.callPackage ./hs { };

      solaar = super.callPackage ./solaar.nix { inherit (super) solaar; };

      tv_time_export = super.callPackage ./tv_time_export.nix { };
    })
]
