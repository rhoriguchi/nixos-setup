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

      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=159074
      remarshal = super.python3Packages.callPackage (import "${
          super.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "35cd881e3f259836f034330634920aef9c303490";
            sha256 = "sha256-h6nq9WXgP/ucMUJsgkzQxWW/OqNZf/+hE5Csg/EhctY=";
          }
        }/pkgs/development/python-modules/remarshal") { };

      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=158792
      plexRaw = super.python3Packages.callPackage (import "${
          super.fetchFromGitHub {
            owner = "rhoriguchi";
            repo = "nixpkgs";
            rev = "c94116d5eea9885973c8fbddc01ce6c8bfbea204";
            sha256 = "sha256-AbEFsOdb7R+TRIiBlN3Ahm5IZJ3HMQUUl9WrJGQHP8E=";
          }
        }/pkgs/servers/plex/raw.nix") { };
    })
]
