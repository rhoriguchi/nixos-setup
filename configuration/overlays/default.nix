[
  (self: super: {
    mach-nix = import (super.fetchFromGitHub {
      owner = "DavHau";
      repo = "mach-nix";
      rev = "3.4.0";
      hash = "sha256-CJDg/RpZdUVyI3QIAXUqIoYDl7VkxFtNE4JWih0ucKc=";
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

      htop = super.callPackage ./htop.nix { inherit (super) htop; };

      plexPlugins = super.callPackage ./plex-plugins { };

      solaar = super.callPackage ./solaar.nix { inherit (super) solaar; };

      tv_time_export = super.callPackage ./tv_time_export.nix { };

      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=166268
      resilio-sync = super.python3Packages.callPackage (import "${
          super.fetchFromGitHub {
            owner = "rhoriguchi";
            repo = "nixpkgs";
            rev = "b98ecf51da6e9b96ee7bc8ea25a2337933379ee5";
            sha256 = "sha256-UixZO2Q/do++f7tBfz3t5DXxqQzA0zWcsruHpRIpMnA=";
          }
        }/pkgs/applications/networking/resilio-sync") { };

      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=166335
      python3Packages = super.python3Packages // {
        pycurl = super.python3Packages.callPackage (import "${
            super.fetchFromGitHub {
              owner = "NixOS";
              repo = "nixpkgs";
              rev = "c270defab79e46b4c98039b09ab6209d1a69ffb3";
              sha256 = "sha256-9MNVbCiD6JbLnWZWNekscqW0j2enhAOu5kdBMXOuLl4=";
            }
          }/pkgs/development/python-modules/pycurl") { };
      };

      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=167602
      plexRaw = super.python3Packages.callPackage (import "${
          super.fetchFromGitHub {
            owner = "rhoriguchi";
            repo = "nixpkgs";
            rev = "d7a6ec66b092131ccda42d236f1eb052954f39a1";
            sha256 = "sha256-ztaUzws50haIjwHER8358XS2Xa0mnutWhdcPXduz+7M=";
          }
        }/pkgs/servers/plex/raw.nix") { };

      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=167693
      yaru-theme = super.callPackage (import "${
          super.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "704a56341ca7e2ddddb8546a3e1bfe3e4ebcedc4";
            sha256 = "sha256-PPc3o2IAUvYlbDHaSjeUDkUgsRHQqtIkwtzNF7u17Xw=";
          }
        }/pkgs/data/themes/yaru") { };
    })
]
