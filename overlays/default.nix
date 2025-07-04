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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=419064
    sonarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "e9deb974dc8fdec543e1267942dbb36690432eac";
          sha256 = "sha256-f+2UfVt23AC8PkGoSoCmAbDgv1Hm0Ewwx8fm+ZOXsQE=";
        }
      }/pkgs/by-name/so/sonarr/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=419685
    netdata = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "3f82b9d3ac9e29c1caab73f3cbd38fa53e527be8";
          sha256 = "sha256-sPcwTGU9oY9qc6qGYMO8XsvaiBoJfeJaUzmw/Wo9Les=";
        }
      }/pkgs/tools/system/netdata") { protobuf = super.protobuf_21; };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=420648
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "2efd2058337e1d55c1e55a4caf98d72cf9e9f6f5";
          sha256 = "sha256-4aY2JwmGCejipECGDOi/P91Zwk+FbCu/TjYCZGcxHHQ=";
        }
      }/pkgs/servers/adguardhome") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=420791
    steam-lancache-prefill = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "69e96cf207b91a072b1b08475adbabc8cb51e5c4";
          sha256 = "sha256-cM1nU76wdm3n8tGWk9A1AKEy3uLW7TElEvmLZJ8TUGE=";
        }
      }/pkgs/by-name/st/steam-lancache-prefill/package.nix") { };
  })
  (_: super: {
    discord = super.callPackage ./discord.nix { inherit (super) discord; };

    hs = super.callPackage ./hs { };
  })
]
