[
  (self: super: {
    mach-nix = import (super.fetchFromGitHub {
      owner = "DavHau";
      repo = "mach-nix";
      rev = "3.3.0";
      sha256 = "105d6b6kgvn8kll639vx5adh5hp4gjcl4bs9rjzzyqz7367wbxj6";
    }) {
      pkgs = super;

      # TODO remove when mach-nix updated
      # Taken from https://github.com/DavHau/pypi-deps-db/commits/master
      pypiDataRev = "82003f187cea48a11fa4816ae2d0304725258e8d";
      pypiDataSha256 = "0igb36riamgxj0kv8ibfryzglxc286g8c0dq2hn433sbpnz80vd3";
    };
  })
  (self: super:
    let nur = import (fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { pkgs = super; };
    in {
      audio-converter = super.callPackage ./audio-converter { };

      discord = super.callPackage ./discord.nix { inherit (super) discord; };

      firefox-addons = nur.repos.rycee.firefox-addons;

      glances = super.callPackage ./glances.nix { inherit (super) glances; };

      hs = super.callPackage ./hs { };

      htop = super.callPackage ./htop.nix { inherit (super) htop; };

      plexPlugins = super.callPackage ./plex-plugins { };

      solaar = super.callPackage ./solaar.nix { inherit (super) solaar; };

      tv_time_export = super.callPackage ./tv_time_export.nix { };

      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=154019
      tautulli = super.python3Packages.callPackage (import "${
          super.fetchFromGitHub {
            owner = "rhoriguchi";
            repo = "nixpkgs";
            rev = "72af5962468ca956cf6f9778545aa4a11e05b78e";
            sha256 = "sha256-Xdlh8tMTV9cYfRVO2djdqNZiTuNqzA8WOdivjPRNlsY=";
          }
        }/pkgs/servers/tautulli/default.nix") { };

      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=154310
      yaml-merge = super.callPackage (import "${
          super.fetchFromGitHub {
            owner = "rhoriguchi";
            repo = "nixpkgs";
            rev = "0cacc3a0d6ceb4f170c017180607e4f02308f02c";
            sha256 = "sha256-z+7TRlfyr0tkcGF8YwD4JstvjK55SMUjwJbLLiFklkE=";
          }
        }/pkgs/tools/text/yaml-merge/default.nix") { };
    })
]
