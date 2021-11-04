[
  (self: super: {
    mach-nix = import (super.fetchFromGitHub {
      owner = "DavHau";
      repo = "mach-nix";
      rev = "3.3.0";
      sha256 = "105d6b6kgvn8kll639vx5adh5hp4gjcl4bs9rjzzyqz7367wbxj6";
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

      nixops = (import (super.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixops";
        rev = "45256745cef246dabe1ae8a7d109988f190cd7ef";
        sha256 = "0ni1v8ppg5cf35gq7nzd50kajxzp5zkbzhf022in0fgbjcprlzr2";
      })).default;

      plexPlugins = super.callPackage ./plex-plugins { };

      tv_time_export = super.callPackage ./tv_time_export.nix { };
    })
]
