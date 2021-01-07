{ gnomeExtensions, callPackage }:
gnomeExtensions // {
  unite-shell = callPackage ./unite-shell.nix { };
}
