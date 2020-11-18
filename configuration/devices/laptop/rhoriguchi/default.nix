{ pkgs, config, ... }:
let userName = "rhoriguchi";
in {
  imports = [ ./dotfiles ./theme ];

  users.users."${userName}" = {
    extraGroups = [ "docker" "networkmanager" "vboxusers" "wheel" ];
    home = "/home/${userName}";
    isNormalUser = true;
  };

  # TODO make firefox default browser https://askubuntu.com/questions/16621/how-to-set-the-default-browser-from-the-command-line
}
