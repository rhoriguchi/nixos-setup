{ gnomeExtensions, callPackage }:
gnomeExtensions // {
  desktop-icons = callPackage ./desktop-icons.nix { };
  unite-shell = callPackage ./unite-shell.nix { };
}
