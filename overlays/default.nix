[
  (self: super: {
    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=181856
    gitkraken = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "e12aa0bb9e0d9392cb9d6158e2cea36611bb38a8";
          sha256 = "sha256-6AicdbFzWft4c6rCjm2XJ8KCvrnZM0/lGi8csFoSN7w=";
        }
      }/pkgs/applications/version-management/gitkraken") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=185250
    adguardhome = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "5c85216634915fcc8d57e4db4c2e22be16d4ca05";
          sha256 = "sha256-0sm5L/VdphC1neSOJh+Crf7ZG8VkJXc5mr8Oe+hEza8=";
        }
      }/pkgs/servers/adguardhome") { };

    # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=185611
    fancy-motd = super.callPackage (import "${
        super.fetchFromGitHub {
          owner = "rhoriguchi";
          repo = "nixpkgs";
          rev = "2ab97a70bbb0f7c5c79e3a52dac4cd910ef093d0";
          sha256 = "sha256-iQd1gYbARvaJRaunOCRT+7HMUiPmt7nYUzVmX6DzcYY=";
        }
      }/pkgs/tools/system/fancy-motd") { };
  })
  (self: super: {
    discord = super.callPackage ./discord.nix { inherit (super) discord; };

    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };

    glances = super.callPackage ./glances.nix { inherit (super) glances; };

    hs = super.callPackage ./hs { };

    solaar = super.callPackage ./solaar.nix { inherit (super) solaar; };

    tv_time_export = super.callPackage ./tv_time_export.nix { };
  })
]
