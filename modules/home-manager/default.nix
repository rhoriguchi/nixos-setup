{ lib, ... }:
let
  getFiles = dir: lib.attrNames (builtins.readDir dir);
  getImports = dir: map (file: dir + "/${file}") (lib.filter (file: file != "default.nix") (getFiles dir));
in {
  imports = getImports ./.;

  home.stateVersion = "22.11";

  news.display = "silent";

  manual = {
    html.enable = false;
    json.enable = false;
  };
}
