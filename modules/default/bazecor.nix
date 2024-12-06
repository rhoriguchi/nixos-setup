# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=359143

let
  src = let
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "a922c21b70768fed304f73ae3c139a02d7583c00";
    sha256 = "sha256:045ggc85krng4pks9fcwf2iqavrq307b9nlp3zxmxil5yvbxsfpw";
  in builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };
in { imports = [ "${src}/nixos/modules/programs/bazecor.nix" ]; }
