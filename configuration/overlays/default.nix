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

      firefox-addons = nur.repos.rycee.firefox-addons;

      glances = super.callPackage ./glances.nix { inherit (super) glances; };

      hs = super.callPackage ./hs { };

      htop = super.callPackage ./htop.nix { inherit (super) htop; };

      plexPlugins = super.callPackage ./plex-plugins { };

      solaar = super.callPackage ./solaar.nix { inherit (super) solaar; };

      tv_time_export = super.callPackage ./tv_time_export.nix { };

      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=157829
      plexRaw = super.python3Packages.callPackage (import "${
          super.fetchFromGitHub {
            owner = "rhoriguchi";
            repo = "nixpkgs";
            rev = "824694e8d85aea9edb5019c6ee7fbb5a2a752ca3";
            sha256 = "sha256-Z6X8ttc0QiUrC5B9uIG+6lfUc7BywUKYaKKpxSaQ0xQ=";
          }
        }/pkgs/servers/plex/raw.nix") { };
    })
]
