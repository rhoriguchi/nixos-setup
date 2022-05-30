[
  (self: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=168911
    glances = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "b328c99d10acfff3532c3a12651422238d0de9a2";
          sha256 = "sha256-o4zTwnHmgIDgbGEe83dmtYs/J1TPTaN3MGe3qWQnv/4=";
        }
      }/pkgs/applications/system/glances") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=175497
    fancy-motd = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "4aec3b1e27b797f77d3091f14fb3eab69123d50c";
          sha256 = "sha256-yXPVCaxAv4eXvPIXThNwL4F/pzbzo2r38lC9asnhpic=";
        }
      }/pkgs/tools/system/fancy-motd") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=175504
    tautulli = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "8660898de1ed9fef30da3ea41ceadd58a055b560";
          sha256 = "sha256-7RBHDjQy7R9vaoMmWyhVOGJFCV2KgkzJ2vJLREiA4qY=";
        }
      }/pkgs/servers/tautulli") { };
  })
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

      solaar = super.callPackage ./solaar.nix { inherit (super) solaar; };

      tv_time_export = super.callPackage ./tv_time_export.nix { };
    })
]
