[
  (self: super: {
    mach-nix = super.callPackage ./mach-nix.nix { pkgs = super; };
  })
  (self: super: {
    displaylink = super.callPackage ./displaylink {
      inherit (super) displaylink;
      inherit (super.linuxPackages) evdi;
    };
    glances = super.callPackage ./glances.nix { inherit (super) glances; };
    gnomeExtensions =
      super.callPackage ./gnomeExtensions { inherit (super) gnomeExtensions; };
    protonvpn-cli =
      super.callPackage ./protonvpn-cli { inherit (super) protonvpn-cli; };
    mal_export = super.callPackage ./mal_export.nix { };
    terraform_0_14 =
      super.callPackage ./terraform.nix { inherit (super) terraform_0_14; };
    tv_time_export = super.callPackage ./tv_time_export.nix { };
  })
]
