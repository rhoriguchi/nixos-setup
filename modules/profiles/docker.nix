{ pkgs, lib, ... }: {
  virtualisation.docker = {
    enable = true;

    logDriver = "json-file";
    extraOptions = lib.concatStringsSep " " [ "--log-opt max-file=10" "--log-opt max-size=10m" ];
  };

  environment.systemPackages = [ pkgs.docker-compose ];
}
