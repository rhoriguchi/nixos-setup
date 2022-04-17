{ lib, config, pkgs, ... }: {
  programs.zsh.enable = true;

  system.activationScripts.createZshrc = lib.mkIf config.programs.zsh.enable (let
    normalUsers = lib.filter (user: user.isNormalUser == true) (lib.attrValues config.users.users);
    commands = map (user: "touch ${user.home}/.zshrc") normalUsers;
  in lib.concatStringsSep "\n" commands);

  users.defaultUserShell = pkgs.zsh;
}
