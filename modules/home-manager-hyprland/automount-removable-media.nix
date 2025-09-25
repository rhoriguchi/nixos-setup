{ pkgs, ... }:
{
  services.udiskie = {
    enable = true;

    tray = "auto";
    settings.program_options.file_manager = "${pkgs.nautilus}/bin/nautilus";
  };
}
