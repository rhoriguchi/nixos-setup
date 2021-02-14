{ glances, formats, lib, stdenv, fetchFromGitHub, python3Packages, makeWrapper
}:
with lib;
let
  configFile = (formats.ini { }).generate "glances.conf" {
    connections.disable = false;
    diskio.hide = "loop\\d+,^mmcblk\\d+$,^sd[a-z]+$";
    fs.hide = "/nix/store";
    global.check_update = false;
    irq.disable = true;
    network.hide = "lo,^br.*$,^veth.*$";
  };

  py3nvml = python3Packages.buildPythonPackage rec {
    pname = "py3nvml";
    version = "0.2.6";

    buildInputs = [
      (python3Packages.buildPythonPackage rec {
        pname = "xmltodict";
        version = "0.12.0";

        doCheck = false;

        src = python3Packages.fetchPypi {
          inherit pname version;
          sha256 = "08cadlb9vsb4pmzc99lz3a2lx6qcfazyvgk10pcqijvyxlwcdn2h";
        };
      })
    ];

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "1jyplsmj85alwzypnd1iy40hg88p6zv6aw80lamq2sqkay5nqhcq";
    };
  };

  pymdstat = python3Packages.buildPythonPackage rec {
    pname = "pymdstat";
    version = "0.4.2";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "1addp6c94dzqwz1pwbwms0cyy1bzid4qbsfn2s3gxzb431pkrxgy";
    };
  };

  pySMART_smartx = python3Packages.buildPythonPackage rec {
    pname = "pySMART.smartx";
    version = "0.3.10";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "16chrzqz3ykpkikfdi71z1g31hm8pij5gs9p6fsxjd6r3awxj1zr";
    };
  };
in glances.overrideAttrs (oldAttrs: {
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ makeWrapper ];

  propagatedBuildInputs = oldAttrs.propagatedBuildInputs
    ++ (with python3Packages; [ docker requests ]) ++ [ py3nvml pySMART_smartx ]
    ++ optional stdenv.isLinux pymdstat;

  postInstall = ''
    wrapProgram $out/bin/glances \
      --add-flags "--config ${configFile}" \
      --add-flags "--time 1" \
      --add-flags "--disable-irix" \
      --add-flags "--byte"
  '';
})
