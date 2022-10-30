{ lib, config, ... }:
let cfg = config.services.sonarr;
in { config = lib.mkIf cfg.enable { systemd.services.sonarr.serviceConfig.UMask = "0002"; }; }
