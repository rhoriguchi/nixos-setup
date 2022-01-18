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

      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=155099
      flameshot = super.libsForQt5.callPackage (import "${
          super.fetchFromGitHub {
            owner = "rhoriguchi";
            repo = "nixpkgs";
            rev = "499c06a14fc11ac144f5f35ec3686470d5ccf522";
            sha256 = "sha256-oxaYMT8PG2aXK+UKPxjtcE36YyAy31dD81+Nlyp6lgg=";
          }
        }/pkgs/tools/misc/flameshot/default.nix") { };

      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=154692
      gnomeExtensions = super.gnomeExtensions // {
        volume-mixer = super.gnomeExtensions.volume-mixer.overrideAttrs (_: {
          postPatch = ''
            substituteInPlace "lib/utils/paHelper.js" \
              --replace "let PYTHON;" "let PYTHON = '${super.python3}/bin/python';" \
              --replace "const args = ['/usr/bin/env', python, paUtilPath, type];" "const args = [python, paUtilPath, type];"
            substituteInPlace "pautils/lib/libpulse.py" --replace "lib = CDLL('libpulse.so.0')" "lib = CDLL('${super.pulseaudio}/lib/libpulse.so.0');"
          '';
        });
      };

      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=154756
      plexRaw = super.python3Packages.callPackage (import "${
          super.fetchFromGitHub {
            owner = "rhoriguchi";
            repo = "nixpkgs";
            rev = "ce6f4cb53e8a91959d618777b7dc2f6dc4777340";
            hash = "sha256-A+17eG7KiOxOsygdVijGNx7kFKSjuVlzWv62ZF+dsj8=";
          }
        }/pkgs/servers/plex/raw.nix") { };
    })
]
