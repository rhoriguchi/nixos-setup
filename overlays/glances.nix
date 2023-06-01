{ glances, fetchFromGitHub, formats, lib, stdenv, python3Packages, makeWrapper }:
let
  configFile = (formats.ini { }).generate "glances.conf" {
    connections.disable = false;
    diskio.hide = "loop\\d+,^mmcblk\\d+p\\d+$,^sd[a-z]+\\d+$,^nvme0n\\d+p\\d+$,^dm-\\d+$";
    fs = {
      allow = "cifs,zfs";
      hide = "/nix/store";
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

  # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=235477
  pysmart = python3Packages.callPackage (import "${
      fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "238a26ab0bbc32a0523a71b010fd4ddd23ac3856";
        sha256 = "sha256-JvE8gR221DmNYo8PT7SA3/fQVLu6Fmg0IU8w1XS9TOs=";
      }
    }/pkgs/development/python-modules/pysmart") { };
in glances.overrideAttrs (oldAttrs: {
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ makeWrapper ];

  propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
    py3nvml
    pysmart
    python3Packages.batinfo
    python3Packages.docker
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
