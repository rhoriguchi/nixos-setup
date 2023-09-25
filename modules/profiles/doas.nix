{ pkgs, ... }: {
  security = {
    doas.enable = true;
    sudo.enable = false;
  };

  environment.shellAliases.test-sudo = "${pkgs.doas-sudo-shim}/bin/sudo";
}
