[
  (_: super: {
    # Resilio Sync 3.0.2.1058 will break after a while
    resilio-sync = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "4f0dadbf38ee4cf4cc38cbc232b7708fddf965bc";
          sha256 = "sha256-jQNGd1Kmey15jq5U36m8pG+lVsxSJlDj1bJ167BjHQ4=";
        }
      }/pkgs/by-name/re/resilio-sync/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=413906
    prowlarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "51f9736368c444ee586a388374bce7f9e655b52d";
          sha256 = "sha256-mfrh3eG5mZSIatf+dW213E8nB600f7VbnOr1D2KgJws=";
        }
      }/pkgs/by-name/pr/prowlarr/package.nix") { };
  })
  (_: super: {
    discord = super.callPackage ./discord.nix { inherit (super) discord; };

    hs = super.callPackage ./hs { };

    steam-lancache-prefill = super.callPackage ./steam-lancache-prefill { };
  })
]
