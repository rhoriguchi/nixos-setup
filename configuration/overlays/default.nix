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

      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=168465
      tautulli = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "rhoriguchi";
          repo = "nixpkgs";
          rev = "32e297d50e684bf5a70a9ee86c8110961c42320c";
          sha256 = "sha256-LB35TkiuDa4EI1e3dY28huU0WJVTLOJfIUWjIAHIPMI=";
        }
      }/pkgs/servers/tautulli") { };
    })
]
