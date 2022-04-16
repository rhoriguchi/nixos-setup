{ lib, config, ... }: {
  console = {
    keyMap = lib.mkIf (!config.services.xserver.enable) "de_CH-latin1";
    useXkbConfig = lib.mkIf config.services.xserver.enable true;
  };

  services.xserver = lib.mkIf config.services.xserver.enable {
    layout = "ch";
    xkbModel = "pc105";
    xkbVariant = "de_nodeadkeys";
  };
}
