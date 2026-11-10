{
  config,
  lib,
  pkgs,
  ...
}:
let
  iniFormat = pkgs.formats.ini { };
in
{
  services.geoclue2.enable = true;

  environment.etc."geoclue/conf.d/ip.conf" =
    lib.mkIf (config.services.geoclue2.enable && config.networking.networkmanager.unmanaged != [ ])
      {
        source = iniFormat.generate "geoclue-ip.conf" {
          ip = {
            enable = true;
            method = "ichnaea";
          };
        };
      };
}
