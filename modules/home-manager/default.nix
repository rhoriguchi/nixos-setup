{ lib, ... }:
{
  imports = lib.custom.getImports ./.;

  home.stateVersion = "26.05";

  news.display = "silent";

  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };
}
