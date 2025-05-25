{ lib, ... }: {
  imports = lib.custom.getImports ./.;

  home.stateVersion = "25.11";

  news.display = "silent";

  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };
}
