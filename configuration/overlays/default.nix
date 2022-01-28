[
  (self: super: {
    mach-nix = import (super.fetchFromGitHub {
      owner = "DavHau";
      repo = "mach-nix";
      rev = "3.3.0";
      hash = "sha256-RvbFjxnnY/+/zEkvQpl85MICmyp9p2EoncjuN80yrYA=";
    }) {
      pkgs = super;

      # TODO remove when mach-nix updated
      # Taken from https://github.com/DavHau/pypi-deps-db/commits/master
      pypiDataRev = "f251b0ec37b796d7ac4125251d65724427870ef0";
      pypiDataSha256 = "1zgfn5zy44pm5m8qn4nisdjw35lp94wa5v8g2hn6r46wmx3b11f8";
    };
  })
  (self: super:
    let nur = import (fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { pkgs = super; };
    in {
      discord = super.callPackage ./discord.nix { inherit (super) discord; };

      firefox-addons = nur.repos.rycee.firefox-addons;

      glances = super.callPackage ./glances.nix { inherit (super) glances; };

      hs = super.callPackage ./hs { };

      htop = super.callPackage ./htop.nix { inherit (super) htop; };

      plexPlugins = super.callPackage ./plex-plugins { };

      solaar = super.callPackage ./solaar.nix { inherit (super) solaar; };

      tv_time_export = super.callPackage ./tv_time_export.nix { };
    })
]
