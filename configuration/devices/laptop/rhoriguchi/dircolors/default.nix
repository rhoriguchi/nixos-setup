{ ... }: {
  # TODO does not work
  home-manager.users.rhoriguchi.programs.dircolors = {
    enable = true;
    extraConfig = builtins.readFile ./dircolors;
  };
}
