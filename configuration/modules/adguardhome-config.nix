{ lib, config, pkgs, ... }:
let
  cfg = config.services.adguardhome;

  args = builtins.concatStringsSep " " ([
    "--no-check-update"
    "--pidfile /run/AdGuardHome/AdGuardHome.pid"
    "--work-dir /var/lib/AdGuardHome/"
    "--config /var/lib/AdGuardHome/AdGuardHome.yaml"
    "--host ${cfg.host}"
    "--port ${toString cfg.port}"
  ] ++ cfg.extraArgs);

  configFile = (pkgs.formats.yaml { }).generate "AdGuardHome.yaml" cfg.config;

  execStart = pkgs.writeShellScript "adguardhome-execStart" ''
    ${pkgs.coreutils}/bin/cp -f /var/lib/AdGuardHome/AdGuardHome.yaml /var/lib/AdGuardHome/AdGuardHome.old.yaml || true
    ${pkgs.coreutils}/bin/cp -f ${configFile} /var/lib/AdGuardHome/AdGuardHome.yaml
    ${pkgs.coreutils}/bin/chmod 0644 /var/lib/AdGuardHome/AdGuardHome.yaml /var/lib/AdGuardHome/AdGuardHome.yaml
    ${pkgs.adguardhome}/bin/adguardhome ${args}
  '';
in {
  options.services.adguardhome.config = lib.mkOption {
    default = { };

    type = let
      valueType = lib.types.nullOr (lib.types.oneOf [
        lib.types.bool
        lib.types.float
        lib.types.int
        lib.types.str
        (lib.types.lazyAttrsOf valueType)
        (lib.types.listOf valueType)
      ]);
    in valueType;
  };

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = cfg.config != null;
      message = "Config cannot be empty.";
    }];

    systemd.services.adguardhome.serviceConfig.ExecStart = lib.mkIf (cfg.config != { }) (lib.mkForce execStart);
  };
}
