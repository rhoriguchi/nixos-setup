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

    home-assistant-custom-components = super.home-assistant-custom-components // {
      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=383209
      localtuya = super.callPackage (import "${
          super.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "0aaa430cbe4509bbe176777cf0ce289e5b04c6e5";
            sha256 = "sha256-3nEKtG7o3oVYaWrnytzdsPV8ZvZp/PpElQkIgumreCM=";
          }
        }/pkgs/servers/home-assistant/custom-components/localtuya/package.nix") { };
    };
  })
  (_: super: {
    discord = super.callPackage ./discord.nix { inherit (super) discord; };

    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };

    flameshot = super.flameshot.overrideAttrs {
      cmakeFlags = [ (super.lib.cmakeBool "USE_WAYLAND_GRIM" true) (super.lib.cmakeBool "USE_WAYLAND_CLIPBOARD" true) ];
    };

    hs = super.callPackage ./hs { };
  })
]
