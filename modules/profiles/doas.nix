{ pkgs, ... }:
{
  security = {
    doas.enable = true;
    sudo.enable = false;
  };

  environment.shellAliases.sudo = "${pkgs.doas-sudo-shim}/bin/sudo";
}
