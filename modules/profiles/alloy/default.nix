{
  config,
  lib,
  ...
}:
{
  imports = [
    ./borgmatic.nix
    ./containers.nix
  ];

  services.alloy.extraFlags = [ "--disable-reporting" ];

  environment.etc = lib.mkIf config.services.alloy.enable {
    "alloy/debug.alloy".text = ''
      livedebugging {
        enabled = true
      }
    '';
  };
}
