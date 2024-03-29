{ glances, formats, lib, stdenv, python3Packages, makeWrapper }:
let
  configFile = (formats.ini { }).generate "glances.conf" {
    connections.disable = false;
    diskio.hide = "loop\\d+,^mmcblk\\d+p\\d+$,^sd[a-z]+\\d+$,^nvme0n\\d+p\\d+$,^dm-\\d+$";
    fs = {
      allow = "cifs,zfs";
      hide = builtins.storeDir;
    };
    global.check_update = false;
    irq.disable = true;
    network.hide = "lo,^br.*$,^veth.*$";
  };

  py3nvml = python3Packages.buildPythonPackage rec {
    pname = "py3nvml";
    version = "0.2.6";

    buildInputs = [ python3Packages.xmltodict ];

    src = python3Packages.fetchPypi {
      inherit pname version;
      hash = "sha256-mEFsi1cTa4GrogBxZfY3F6EHAfExNHv951QVJKum18s=";
    };
  };
in glances.overrideAttrs (oldAttrs: {
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ makeWrapper ];

  propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
    py3nvml
    python3Packages.batinfo
    python3Packages.docker
    python3Packages.pysmart
    python3Packages.python-dateutil
    python3Packages.requests
    python3Packages.sparklines
  ] ++ lib.optional stdenv.isLinux python3Packages.pymdstat;

  postInstall = (oldAttrs.postInstall or "") + ''
    wrapProgram $out/bin/glances \
      --add-flags "--config ${configFile}" \
      --add-flags "--time 1" \
      --add-flags "--disable-irix" \
      --add-flags "--byte"
  '';
})
