{ pkgs, config, ... }:
let home = config.users.users.rhoriguchi.home;
in {
  imports = [ ./dconf ./dotfiles ];

  # TODO make eog default image viewer
  # TODO make firefox default browser https://askubuntu.com/questions/16621/how-to-set-the-default-browser-from-the-command-line
}
