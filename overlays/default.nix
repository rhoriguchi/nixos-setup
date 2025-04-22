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
          rev = "f53da7475f3e9cb99655449b95caef2a5781569e";
          sha256 = "sha256-/albFFaFxb2FJBQQ4uy16ui4TQIZQbIrCkpAD4cznaA=";
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
