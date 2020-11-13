{ stdenv, fetchFromGitHub, lib, makeWrapper, rsync, utillinux }:
stdenv.mkDerivation rec {
  pname = "log2ram";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "azlux";
    repo = pname;
    rev = version;
    sha256 = "1dsd4h52afjw5nkjyqi4kxgnc2j588sgs04qhkawikxwpnphbzzr";
  };

  dontConfigure = true;

  dontBuild = true;

  installPhase = "install -D -m0755 log2ram $out/bin/log2ram";

  nativeBuildInputs = [ makeWrapper ];

  postFixup = "wrapProgram $out/bin/${pname} --prefix PATH : ${
      lib.makeBinPath [ rsync utillinux ]
    }";
}
