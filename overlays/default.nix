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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=410196
    superfile = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "fe3d05435bbaba0646df7fc4ced94926cac170a5";
          sha256 = "sha256-+wAVdaU4D4JT3iskU3FqHcdtW4vYOgLDvHxaT/SAWdA=";
        }
      }/pkgs/by-name/su/superfile/package.nix") { };
  })
  (_: super: {
    discord = super.callPackage ./discord.nix { inherit (super) discord; };

    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };

    hs = super.callPackage ./hs { };

    steam-lancache-prefill = super.callPackage ./steam-lancache-prefill { };
  })
]
