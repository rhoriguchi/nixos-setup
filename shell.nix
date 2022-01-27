let
  nixpkgs = let
    commit = "f74ffdfc36046edd90b3d12cf8d716242183be74";
    sha256 = "1pjd6mrmw3iaf12s9d1fg1ra42fpyn3yfvrfb6wkl33ggbslwfa2";
  in fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${commit}.tar.gz";
    inherit sha256;
  };

  pkgs = import nixpkgs { config = { }; };
in pkgs.mkShell {
  buildInputs = [ pkgs.nixopsUnstable ];

  shellHook = ''
    export NIX_PATH="nixpkgs=${nixpkgs}:."
  '';
}
