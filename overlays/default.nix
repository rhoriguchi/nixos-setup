[
  (_: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=390165
    netdata = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "547813ca4c118818947eccbb63be2506b5bbcdfd";
          sha256 = "sha256-vS6cy1MTBcqAt2bWxMgbWCAOFVOzX83l2dSDPKlQymE=";
        }
      }/pkgs/tools/system/netdata") { protobuf = super.protobuf_21; };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=393454
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "a2412aa76dfd419d2acdd430581bb47410d93471";
          sha256 = "sha256-ALLPqPr6tAE6IfQBTCweNsL1zJCtQ3LMzKxaSa2INyM=";
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
