{ glances, formats, lib, stdenv, python3Packages, makeWrapper }:
let
  configFile = (formats.ini { }).generate "glances.conf" {
    connections.disable = false;
    diskio.hide = "loop\\d+,^mmcblk\\d+p\\d+$,^sd[a-z]+\\d+$,^nvme0n\\d+pd+$,^dm-\\d+$";
    fs.hide = "/nix/store";
    global.check_update = false;
    irq.disable = true;
    network.hide = "lo,^br.*$,^veth.*$";
  };

  sparklines = python3Packages.buildPythonPackage rec {
    pname = "sparklines";
    version = "0.4.2";

    buildInputs = [ python3Packages.future ];

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "125fvkqibs18j51jy82qprl5qy4ayn6l4ccvfbyv2xxjr1nzscvw";
    };

    doCheck = false;
  };

  py3nvml = python3Packages.buildPythonPackage rec {
    pname = "py3nvml";
    version = "0.2.6";

    buildInputs = [ python3Packages.xmltodict ];

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
    ++ [ py3nvml pySMART_smartx python3Packages.docker python3Packages.requests sparklines ] ++ lib.optional stdenv.isLinux pymdstat;

  postInstall = ''
    wrapProgram $out/bin/glances \
      --add-flags "--config ${configFile}" \
      --add-flags "--time 1" \
      --add-flags "--disable-irix" \
      --add-flags "--byte"
  '';
})
