{ gnomeExtensions, callPackage }:
gnomeExtensions // {
  clock-override = callPackage ./clock-override.nix { };
  unite-shell = callPackage ./unite-shell.nix { };
  gnome-fuzzy-app-search = callPackage ./gnome-fuzzy-app-search.nix { };
}
