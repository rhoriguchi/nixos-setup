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
  })
  (self: super: {
    mach-nix = import (super.fetchFromGitHub {
      owner = "DavHau";
      repo = "mach-nix";
      # TODO pin version once version newer than 3.5.0 is released
      rev = "51caf584f26acdfaa51bbf7ee1ffa365aea7bc64";
      hash = "sha256-qSjk1iOi14ijAOP6QuGfE3fvy08aVxsgus+ArwgiyuU=";
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
