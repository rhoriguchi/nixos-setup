[
  (self: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=178522
    flameshot = super.libsForQt5.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "ddeb50d445e65fc7d6bedd2dd347439e62fc4450";
          sha256 = "sha256-FP/wg/B/Ghf1YPVJ22u71/mr1LzNGyE9zThV7/pcdIM=";
        }
      }/pkgs/tools/misc/flameshot") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=178629
    onedrive = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "5a606bc7b9c3b831177036b04910c924f25ddf6f";
          sha256 = "sha256-JLMti3Y4dW7RFif+BgbYI1Q/wYLEHuw9Xs8d14xbktE=";
        }
      }/pkgs/applications/networking/sync/onedrive") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=178811
    nixopsUnstable = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "ea7336a084a37d99548781ddeb4de41f394ca3f1";
          sha256 = "sha256-wa/IIm7o93DwRfKF6w5YRI3qSG9T7dxC8iNiisdJA04=";
        }
      }/pkgs/applications/networking/cluster/nixops") { };
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
