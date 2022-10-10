# TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=195273

{ pkgs, lib, config, ... }:
let cfg = config.services.prowlarr;
in {
  options.services.prowlarr.dataDir = lib.mkOption {
    type = lib.types.str;
    default = "/var/lib/prowlarr";
    description = lib.mdDoc "The directory where Prowlarr stores its data files.";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.prowlarr.serviceConfig.ExecStart = lib.mkForce "${pkgs.prowlarr}/bin/Prowlarr -nobrowser -data='${cfg.dataDir}'";
  };
}
