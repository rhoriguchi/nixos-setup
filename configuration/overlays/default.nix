[
  (self: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=181856
    gitkraken = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "57321e6b14fdbefbe0c107625b6b22a823845dd9";
          sha256 = "sha256-dt7oqbcjbKbqpItMFgPabBLNYNpMaWde5Iyyu2N3YBw=";
        }
      }/pkgs/applications/version-management/gitkraken/default.nix") { };
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
