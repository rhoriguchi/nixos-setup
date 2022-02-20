{ lib, ... }: {
  home-manager.users.rhoriguchi.programs.bat = {
    enable = true;

    config = {
      paging = "never";
      style = lib.concatStringsSep "," [ "numbers" ];
      tabs = "4";
      theme = "ansi";
    };
  };
}
