{
  config,
  lib,
  ...
}:
{
  services.alloy.extraFlags = [ "--disable-reporting" ];

  environment.etc = lib.optionalAttrs config.services.alloy.enable {
    "alloy/debug.alloy".text = ''
      livedebugging {
        enabled = true
      }
    '';
  };
}
