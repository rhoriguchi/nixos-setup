[
  (self: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=175497
    fancy-motd = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "43629f3d2e57da46b403b681909c324a7614aa1d";
          sha256 = "sha256-fqelKP+5oXcMLvdQmXluW8738IZqHups0GezqkgHncs=";
        }
      }/pkgs/tools/system/fancy-motd") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=175504
    tautulli = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "e673666c66d4c1491048f6cacfca2b3ad3977356";
          sha256 = "sha256-21iV/lNT5l14HhjqHtiuQvNtV8k6L1EiafBLmYHxczM=";
        }
      }/pkgs/servers/tautulli") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=178629
    onedrive = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "5a606bc7b9c3b831177036b04910c924f25ddf6f";
          sha256 = "sha256-JLMti3Y4dW7RFif+BgbYI1Q/wYLEHuw9Xs8d14xbktE=";
        }
      }/pkgs/applications/networking/sync/onedrive") { };
  })
  (self: super: {
    mach-nix = import (super.fetchFromGitHub {
      owner = "DavHau";
      repo = "mach-nix";
      rev = "3.5.0";
      hash = "sha256-j/XrVVistvM+Ua+0tNFvO5z83isL+LBgmBi9XppxuKA=";
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
