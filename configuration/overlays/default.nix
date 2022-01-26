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
      pypiDataRev = "b780f2b5447d4cdfa60f8823e075d47f394c9410";
      pypiDataSha256 = "1qybx0f5ym8x69ha0k7f0s3qmfdybd3a2s5k6bpp6jabnsinl5x8";
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

      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=156721
      adguardhome = super.callPackage (import "${
          super.fetchFromGitHub {
            owner = "rhoriguchi";
            repo = "nixpkgs";
            rev = "aae7730128579abbd50dee81c3d3695918a6137f";
            hash = "sha256-7IyM4g3225EfzlOrCk8pdi6WZg1JRyQN+PhfagrrlIY=";
          }
        }/pkgs/servers/adguardhome/default.nix") { };
    })
]
