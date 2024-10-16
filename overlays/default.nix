[
  (_: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=185611
    fancy-motd = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "4fd5da3781ed6d12a139bee1c84d17772edf130c";
          hash = "sha256-VlvxAWOKZ/ih7bxKxD2qfp2S8skGABS90hfmP8aV2w0=";
        }
      }/pkgs/tools/system/fancy-motd") { };

    pythonPackagesExtensions = super.pythonPackagesExtensions ++ [
      (py-final: _: {
        # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=348902
        onnx = py-final.callPackage (import "${
            super.fetchFromGitHub {
              owner = "NixOS";
              repo = "nixpkgs";
              rev = "073433e829b59a0d70009cc80f92570988a2e91d";
              hash = "sha256-hid85oPKY3T4EUoMC2FlJwDG9ug2loo1wCWUM2DV7/U=";
            }
          }/pkgs/development/python-modules/onnx") { };
      })
    ];
  })
  (_: super: {
    discord = super.callPackage ./discord.nix { inherit (super) discord; };

    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };

    glances = super.callPackage ./glances.nix { inherit (super) glances; };

    hs = super.callPackage ./hs { };
  })
]
