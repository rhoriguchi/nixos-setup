{ pkgs, ... }: {
  security = {
    doas.enable = true;
    sudo.enable = false;
  };

  environment.shellAliases.sudo = "${pkgs.buildPackages.doas}/bin/doas";
}
