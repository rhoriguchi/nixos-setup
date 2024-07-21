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

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=319032
    netdata = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "57eccbb4deed82851c54c18d67a1a15e3465767a";
          hash = "sha256-QVn7G9WZte4WIBNwL3p2x8OmLpP7XtfinPSadkAXZN4=";
        }
      }/pkgs/tools/system/netdata") {
        inherit (super.darwin.apple_sdk.frameworks) CoreFoundation IOKit;
        protobuf = super.protobuf_21;
      };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=325186
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "6b75aa0af800b0cc6d2a2d6aef160a77c0660240";
          sha256 = "sha256-a3TX+difrenFlc1jgeHvvXlYTQx5h3P3SF3ZXmsqHtA=";
        }
      }/pkgs/servers/adguardhome") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=325327
    prowlarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "bee394b999ba9f3456914072b51a48dd052a11f5";
          sha256 = "sha256-KKbGEdwAb17SmmjM4axTba9w5qNQE0+wYe7ds8O8pyw=";
        }
      }/pkgs/servers/prowlarr") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=328978
    sonarr = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "7667d760f1e89978de903f2c0c2755a83d6e095f";
          sha256 = "sha256-W2MjSPz2psj/JFqgP4btRVQFyumQi1csC0SVi17oXxg=";
        }
      }/pkgs/by-name/so/sonarr/package.nix") { };
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
