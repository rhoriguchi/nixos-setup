[
  (_: super: {
    gnomeExtensions = super.gnomeExtensions // {
      # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=385948
      unite = super.callPackage (import "${
          super.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "a7c108c44e8ae878e6dec01563e79381ea6a446f";
            hash = "sha256-2H3KyY2mw969VCLZOXwMOyhNZbtS1vSSCxSxbrGaYe8=";
          }
        }/pkgs/desktops/gnome/extensions/unite/default.nix") { };
    };

    vscode-extensions = super.vscode-extensions // {
      ms-python = super.vscode-extensions.ms-python // {
        # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=387839
        python = super.callPackage (import "${
            super.fetchFromGitHub {
              owner = "NixOS";
              repo = "nixpkgs";
              rev = "4886e147e1b285057228cbd7ce2348cf8fb4cb45";
              hash = "sha256-HDRMWYEn1V4kp2wUlwP+fFAvSntBLwTJa2WLQfiVJAc=";
            }
          }/pkgs/applications/editors/vscode/extensions/ms-python.python") { };
      };
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
