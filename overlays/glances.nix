{ glances, lib, stdenv, fetchpatch, python3Packages }:
let
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
in glances.overrideAttrs (oldAttrs: {
  propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
    # containers
    python3Packages.docker
    python3Packages.packaging
    python3Packages.podman
    python3Packages.python-dateutil
    python3Packages.six

    # ip
    python3Packages.podman

    # smart
    pysmart

    # sparklines
    python3Packages.sparklines
  ] ++ lib.optionals stdenv.isLinux [
    # battery
    python3Packages.batinfo

    # raid
    python3Packages.pymdstat

    # wifi
    python3Packages.wifi
  ] ++ lib.optionals stdenv.hostPlatform.isx86 [
    # gpu
    python3Packages.nvidia-ml-py
  ];
})
