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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=411467
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "a98a48a016bb21140f2c2cda316e07a3ab94f4fb";
          sha256 = "sha256-7CUD5UscK6J/Rd4YS/PYDMO7W+6oBUx9MQl2Z1fVhIw=";
        }
      }/pkgs/servers/adguardhome") { };
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
