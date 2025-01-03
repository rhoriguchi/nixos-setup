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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=366659
    prowlarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "5736cebc5c14b9596a6be0cdd586ae4b8a32f036";
          sha256 = "sha256-0gk/ry0C3d9a8PpyMOiZE0Wl+3EkXqQXb3q6rZlSkAY=";
        }
      }/pkgs/servers/prowlarr") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=367144
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "aa4ddca3c3bfb86a33c708d679c40ba2d0f1a49a";
          sha256 = "sha256-ZVZWze5ThOiJyjRjHCUtImBQ2IhwVeiNfZcAaUjmAlU=";
        }
      }/pkgs/servers/adguardhome") { };

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
