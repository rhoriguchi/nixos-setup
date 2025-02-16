{ lib, ... }: {
  getImports = let
    getFiles = dir: lib.attrNames (builtins.readDir dir);
    filter = file:
      if lib.pathIsDirectory file then
        builtins.elem "default.nix" (getFiles file)
      else
        lib.hasSuffix ".nix" file && !(lib.hasSuffix "default.nix" file);
  in dir: lib.filter filter (map (file: dir + "/${file}") (getFiles dir));

  relativeToRoot = lib.path.append ./.;
}
