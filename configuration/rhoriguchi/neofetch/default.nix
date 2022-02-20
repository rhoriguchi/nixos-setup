{
  environment.shellAliases.neofetch = "echo; echo; neofetch";

  home-manager.users.rhoriguchi.xdg.configFile."neofetch/config.conf" = {
    source = ./config.conf;
    force = true;
  };
}
