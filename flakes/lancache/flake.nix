{
  description = "Lancache";

  inputs.cache-domains = {
    url = "github:uklans/cache-domains";
    flake = false;
  };

  outputs = { self, ... }@inputs: { nixosModules.default = import ./module.nix; };
}
