{
  description = "LanCache";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    cache-domains = {
      url = "github:uklans/cache-domains";
      flake = false;
    };
  };

  outputs = { ... }@inputs: {
    nixosModules.default.imports = [ ./module.nix ];

    overlays.default = (_: _: { uklans-cache-domains-src = inputs.cache_domains; });
  };
}
