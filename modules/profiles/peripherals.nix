{
  hardware = {
    logitech.wireless.enable = true;

    openrazer.enable = true;
  };

  programs = {
    bazecor.enable = true;

    solaar = {
      enable = true;

      userService = {
        enable = true;

        extraArgs = [ "--restart-on-wake-up" ];
      };
    };
  };
}
