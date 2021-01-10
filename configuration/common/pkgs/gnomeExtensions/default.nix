{ gnomeExtensions, callPackage }:
gnomeExtensions // {
  unite-shell = callPackage ./unite-shell.nix { };
  gnome-fuzzy-app-search = callPackage ./gnome-fuzzy-app-search.nix { };
}
