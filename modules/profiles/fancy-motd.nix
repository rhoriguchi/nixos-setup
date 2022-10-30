{ pkgs, ... }:
let
  fancyMotdConfig = pkgs.writeText "fancy-motd-config" ''
    # Colors
    CA="\e[35m"  # Accent
    CO="\e[32m"  # Ok
    CW="\e[33m"  # Warning
    CE="\e[31m"  # Error
    CN="\e[0m"   # None

    # Max width used for components in second column
    WIDTH=75

    # Services to show
    unset services
  '';
in {
  environment.shellInit = ''
    if (( EUID != 0 )) && [[ $- == *i* ]]; then
      ${pkgs.fancy-motd}/bin/motd ${fancyMotdConfig}
    fi
  '';
}
