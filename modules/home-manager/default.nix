{ lib, ... }:
let
  getFiles = dir: lib.attrNames (builtins.readDir dir);
  filter = file:
    if lib.pathIsDirectory file then
      builtins.elem "default.nix" (getFiles file)
    else
      lib.hasSuffix ".nix" file && !(lib.hasSuffix "default.nix" file);
  getImports = dir: lib.filter filter (map (file: dir + "/${file}") (getFiles dir));
in {
  imports = getImports ./.;

  home.stateVersion = "25.05";

  nixpkgs.config.allowUnfree = true;

  news.display = "silent";

  manual = {
    html.enable = false;
    json.enable = false;
  };
}
