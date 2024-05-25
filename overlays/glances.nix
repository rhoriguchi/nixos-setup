{ glances, formats, lib, stdenv, fetchpatch, fetchFromGitHub, python3Packages, makeWrapper }:
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

  # TODO remove when merged and release https://github.com/truenas/py-SMART/pull/89
  pysmart = python3Packages.pysmart.overrideAttrs (oldAttrs: {
    doCheck = false;
    doInstallCheck = false;

    patches = (oldAttrs.patches or [ ]) ++ [
      (fetchpatch {
        url = "https://patch-diff.githubusercontent.com/raw/truenas/py-SMART/pull/89.patch";
        sha256 = "sha256-es6Zjw0Tzv34Hn3EhUYlM6Kfw6aKd/H3aEJ0ciBxHxQ=";
      })
    ];
  });

  # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=308031
  sparklines = python3Packages.callPackage (import "${
      fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "c6bd08a21101ac5f1ad4b4a3b5a96530ed595177";
        sha256 = "sha256-PeEehqBBJovDGInFpgEB66Pz8wHdfJMfy/hDJrowFpE=";
      }
    }/pkgs/development/python-modules/sparklines") { };
in glances.overrideAttrs (oldAttrs: {
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ makeWrapper ];

  propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
    py3nvml
    pysmart
    python3Packages.batinfo
    python3Packages.docker
    python3Packages.python-dateutil
    python3Packages.requests
    sparklines
  ] ++ lib.optional stdenv.isLinux python3Packages.pymdstat;

  postInstall = (oldAttrs.postInstall or "") + ''
    wrapProgram $out/bin/glances \
      --add-flags "--config ${configFile}" \
      --add-flags "--time 1" \
      --add-flags "--disable-irix" \
      --add-flags "--byte"
  '';
})
