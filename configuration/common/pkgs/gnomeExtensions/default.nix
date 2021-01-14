{ gnomeExtensions, callPackage }:
gnomeExtensions // {
  clock-override = callPackage ./clock-override.nix { };
  fuzzy-app-search = callPackage ./fuzzy-app-search.nix { };
  unite-shell = callPackage ./unite-shell.nix { };
}
