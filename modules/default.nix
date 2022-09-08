{ lib, ... }:
let
  getFiles = dir: lib.attrNames (builtins.readDir dir);
  getImports = dir: map (file: dir + "/${file}") (lib.filter (file: file != "default.nix") (getFiles dir));
in { imports = getImports ./.; }
