{
  description = "LanCache";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    "fribb-myanimelist-bundle" = {
      url = "github:Fribb/MyAnimeList.bundle";
      flake = false;
    };

    "zeroqi-absolute-series-scanner" = {
      url = "github:ZeroQI/Absolute-Series-Scanner";
      flake = false;
    };
  };

  outputs = { ... }@inputs: {
    nixosModules.default.imports = [ ./module.nix ];

    overlays.default = (_: _: {
      fribb-myanimelist-bundle-src = inputs.fribb-myanimelist-bundle;
      zeroqi-absolute-series-scanner-src = inputs.zeroqi-absolute-series-scanner;
    });
  };
}
