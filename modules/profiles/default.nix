let files = builtins.attrNames (builtins.readDir ./.);
in builtins.listToAttrs (map (name: {
  name = builtins.replaceStrings [ ".nix" ] [ "" ] name;
  value = import (./. + "/${name}");
}) files)
