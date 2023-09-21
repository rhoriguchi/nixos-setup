{
  security = {
    doas.enable = true;
    sudo.enable = false;
  };

  environment.shellAliases.sudo = "doas";
}
