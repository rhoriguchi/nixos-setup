[
  (_: super: {
    resilio-sync = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "4f0dadbf38ee4cf4cc38cbc232b7708fddf965bc";
          sha256 = "sha256-jQNGd1Kmey15jq5U36m8pG+lVsxSJlDj1bJ167BjHQ4=";
        }
      }/pkgs/by-name/re/resilio-sync/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=390165
    netdata = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "2705e75add11ec45b9611f5423600d1c43a2e978";
          sha256 = "sha256-AogSlFS8E06KfaMNDLE2rQ4FtwdQ3/d/OxAYPrB86h0=";
        }
      }/pkgs/tools/system/netdata") { protobuf = super.protobuf_21; };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=393454
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "b563d1ebe1342f6ade1e48f23f63817b01f9fbff";
          sha256 = "sha256-0bGBCjWyfyNe17nhnzZC+TL7Wog2GrnBjifZK77p2v0=";
        }
      }/pkgs/servers/adguardhome") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=397819
    prowlarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "07251d38564ea52ccb36255222709a59c18a5677";
          sha256 = "sha256-+DCwKaFrUQAgFN4DLwQu7/FyX58m35hJ1u6eNaSv7v4=";
        }
      }/pkgs/by-name/pr/prowlarr/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=398235
    plexRaw = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "92ad3c7f9a85aece5e1977a891a5484e4732db37";
          sha256 = "sha256-RCTiS4NOILJOQFEBG+ebt48eY+nL/LW+a2Y81usWc8k=";
        }
      }/pkgs/servers/plex/raw.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=398475
    tautulli = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "8ebe50af63d6819aa4cb6a6becd8d058570dd54f";
          sha256 = "sha256-uuaYys2jg25nWyZiILIBEalnOQe41HKZZSs/zbvZ1P0=";
        }
      }/pkgs/servers/tautulli") { };
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
