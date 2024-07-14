{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.poetry
    pkgs.python3
    pkgs.python3Packages.black
    pkgs.python3Packages.flake8
    pkgs.python3Packages.pylint
    pkgs.python3Packages.pytest
    pkgs.uv
  ];

  environment.shellAliases = {
    pip = "${pkgs.uv}/bin/uv pip";
    venv = "${pkgs.uv}/bin/uv venv";
  };
}
