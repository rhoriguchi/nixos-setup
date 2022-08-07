{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.pipenv
    pkgs.python310 # TODO remove once python 3.10 is default python3
    pkgs.python3Packages.pip
  ];
}
