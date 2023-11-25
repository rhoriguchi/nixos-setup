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

    nodePackages = super.nodePackages // {
      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=267127
      showdown = super.callPackage (import "${
          super.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "731aa7f177991e992a15367fd32cb0a536dfec4b";
            hash = "sha256-pP+eZ1wXfsycfgnHajuvPssDCFbo0obPihl5BIpXuJ4=";
          }
        }/pkgs/tools/text/showdown") { };
    };

    python3 = super.python3.override {
      packageOverrides = _: _: {
        # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=269189
        plum-py = super.python3Packages.callPackage (import "${
            super.fetchFromGitHub {
              owner = "NixOS";
              repo = "nixpkgs";
              rev = "eb7e8003be23b12b41c458ca2a4cc43248c214c7";
              hash = "sha256-JGutp+G0Faka3ue/8sctbCyJAHjIDtk9VwRNnUjCAm8=";
            }
          }/pkgs/development/python-modules/plum-py") { };
      };
    };
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
