{ lib, config, pkgs, ... }:
let cfg = config.services.tautulli;
in {
  # TODO remove when merged https://nixpk.gs/pr-tracker.html?pr=152159

  options.services.tautulli.openFirewall = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Open ports in the firewall for Tautulli.";
  };

  config = lib.mkIf cfg.enable { networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ]; };
}
