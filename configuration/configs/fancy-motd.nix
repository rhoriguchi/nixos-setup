{ pkgs, ... }:
let
  fancyMotdConfig = pkgs.writeText "fancy-motd-config" ''
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
