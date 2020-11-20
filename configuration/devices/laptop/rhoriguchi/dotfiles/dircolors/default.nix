{ ... }:
# TODO hand this over as variable
let username = "rhoriguchi";
in {
  # TODO does not work
  home-manager.users."${username}".programs.dircolors = {
    enable = true;
    extraConfig = builtins.readFile ./dircolors;
  };
}
