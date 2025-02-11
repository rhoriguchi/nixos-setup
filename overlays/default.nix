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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=377156
    prowlarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "03619cd28bcb292fbcd2692cca7bf4ac509a9afd";
          sha256 = "sha256-LPbpicQhYwCG8PeaYwkvgd7cJRQHPr4Nzgrt7HzQKBA=";
        }
      }/pkgs/by-name/pr/prowlarr/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=380045
    sonarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "e16a609fa71d4c8a5263e9d34f952b48b347fa69";
          sha256 = "sha256-9GsyL0JD7gU1ySoERMXyvCyUwDftcAFZ6Xz+FcvIQYE=";
        }
      }/pkgs/by-name/so/sonarr/package.nix") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=380510
    scanservjs = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "715fe98f0e520c9787c2e8a190e4656f05562a56";
          sha256 = "sha256-e1SL6/hnur/0QRT2PFkpYclmDvSb3U7jDpRsSByajzg=";
        }
      }/pkgs/by-name/sc/scanservjs/package.nix") { };
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
