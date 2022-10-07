{ pkgs, ... }: { environment.systemPackages = [ pkgs.pipenv pkgs.poetry pkgs.python3 pkgs.python3Packages.pip ]; }
