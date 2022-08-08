{ pkgs, ... }: { environment.systemPackages = [ pkgs.pipenv pkgs.python3 pkgs.python3Packages.pip ]; }
