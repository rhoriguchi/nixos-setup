{ stdenv, fetchFromGitHub, python39 }:
let pythonWithPackages = python39.withPackages (ps: [ ps.tkinter ps.tzlocal ]);
in stdenv.mkDerivation {
  pname = "py-kms";
  version = "unstable-2021-01-24";

  src = fetchFromGitHub {
    owner = "SystemRage";
    repo = "py-kms";
    rev = "a3b0c85b5b90f63b33dfa5ae6085fcd52c6da2ff";
    hash = "sha256-u0R0uJMQxHnJUDenxglhQkZza3/1DcyXCILcZVceygA=";
  };

  nativeBuildInputs = [ pythonWithPackages ];

  postPatch = ''
    patchShebangs py-kms
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp -r py-kms/. $out/lib

    mkdir -p $out/bin
    ln -s $out/lib/pykms_Server.py $out/bin/pykms
  '';
}
