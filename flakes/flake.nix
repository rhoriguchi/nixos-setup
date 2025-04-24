{
  description = "Local flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    lancach = {
      url = "path:./lancache";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plex = {
      url = "path:./plex";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { ... }@inputs: {
    nixosModules.default.imports = map (input: input.nixosModules.default) [ inputs.lancach inputs.plex ];

    overlays.default = inputs.nixpkgs.lib.composeManyExtensions (map (input: input.overlays.default) [ inputs.lancach ]);
  };
}
