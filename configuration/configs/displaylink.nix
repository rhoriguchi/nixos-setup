{ pkgs, lib, ... }: {
  services.xserver = {
    displayManager.sessionCommands = "${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0";

    videoDrivers = [ "displaylink" "modesetting" ];
  };
}
