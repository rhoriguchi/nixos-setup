{ gnomeExtensions, callPackage }:
gnomeExtensions // {
  fuzzy-app-search = callPackage ./fuzzy-app-search { };
  dynamic-panel-transparency = callPackage ./dynamic-panel-transparency.nix { };
}
