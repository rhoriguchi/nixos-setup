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

    home-assistant-custom-components = super.home-assistant-custom-components // {
      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=423637
      localtuya = super.callPackage (import "${
          super.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "423da7fd1526483bea1c3de0f3bb4541912855fb";
            sha256 = "sha256-H7CFFHxeZowahvR4WcWQ88yYs40DSFeNtCrc95kReDI=";
          }
        }/pkgs/servers/home-assistant/custom-components/localtuya/package.nix") { };
    };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=436471
    prowlarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "f26452c2719c1f31b695c20e35e5d3f81de55d6b";
          sha256 = "sha256-NuSMjzkL9fCeg0EsAQtSKYrCbrPoq09AeM5VuxE84qQ=";
        }
      }/pkgs/by-name/pr/prowlarr/package.nix") { };
  })
  (_: super: {
    discord = super.callPackage ./discord.nix { inherit (super) discord; };

    hs = super.callPackage ./hs { };
  })
]
