{ ... }:
# TODO hand this over as variable
let username = "rhoriguchi";
in {
  home-manager.users."${username}".xdg.configFile."neofetch/config.conf" = {
    source = ./config.conf;
    force = true;
  };
}
