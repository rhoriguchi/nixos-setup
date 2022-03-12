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

      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=163854
      bind = super.callPackage (import "${
          super.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "97aca2672b3255ee45eee4a2b062d67d91917553";
            sha256 = "sha256-EisGyWn3uXAJE5zXm93tGpXmLMpHc+nzg1fhbYq0+kU=";
          }
        }/pkgs/servers/dns/bind") { };
    })
]
