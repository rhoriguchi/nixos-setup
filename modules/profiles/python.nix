{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.pipenv
    pkgs.poetry
    pkgs.python3
    pkgs.python3Packages.black
    pkgs.python3Packages.flake8
    pkgs.python3Packages.pip
    pkgs.python3Packages.pylint
    pkgs.python3Packages.pytest
  ];
}
