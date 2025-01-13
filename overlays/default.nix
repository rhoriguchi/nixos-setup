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
      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=369945
      localtuya = super.callPackage (import "${
          super.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "a34e0f92f7f721886eb1b310c28aa94ce087a664";
            sha256 = "sha256-u1GsB51kBXZy747OkM9iet4MzbpHmKVxynkBSb2FLXo=";
          }
        }/pkgs/servers/home-assistant/custom-components/hass-localtuya/package.nix") { };
    };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=373339
    tautulli = super.python3Packages.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "e337f76cab1360dace456783544b4072c731d920";
          sha256 = "sha256-vLEoTGYwS4PLpzlb2jCy02iMNot/XnIjhk3UxflMj+U=";
        }
      }/pkgs/servers/tautulli") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=372321
    prowlarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "b70e60ed75d38ddaab1fabdd1bb99a8d8ff55a63";
          sha256 = "sha256-nhzwiWZeUdCqx4bYfBwtJcwBvWhRt1f1vTJGb3fMnrY=";
        }
      }/pkgs/servers/prowlarr") { };

  })
  (_: super: {
    discord = super.callPackage ./discord.nix { inherit (super) discord; };

    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };

    hs = super.callPackage ./hs { };
  })
]
