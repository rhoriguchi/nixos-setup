{ lib, ... }:
let
  getFiles = dir: lib.attrNames (builtins.readDir dir);
  getImports = dir: map (file: dir + "/${file}") (lib.filter (file: !(lib.hasSuffix ".md" file) && file != "default.nix") (getFiles dir));
in {
  imports = getImports ./.;

  home.stateVersion = "23.11";

  nixpkgs.config.allowUnfree = true;

  news.display = "silent";

  manual = {
    html.enable = false;
    json.enable = false;
  };
}
