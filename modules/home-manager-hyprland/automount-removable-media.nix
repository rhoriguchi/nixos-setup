{ pkgs, ... }:
{
  services.udiskie = {
    enable = true;

    tray = "auto";
    # TODO remove when https://github.com/nix-community/home-manager/issues/632 fixed
    settings.program_options.file_manager = "${pkgs.nautilus}/bin/nautilus";
  };
}
