{ ... }:
# TODO hand this over as variable
let userName = "rhoriguchi";
in {
  home-manager.users."${userName}".xdg.configFile."neofetch/config.conf" = {
    source = ./config.conf;
    force = true;
  };
}
