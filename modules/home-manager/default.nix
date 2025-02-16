{ lib, ... }: {
  imports = lib.custom.getImports ./.;

  home.stateVersion = "25.05";

  news.display = "silent";

  manual = {
    html.enable = false;
    json.enable = false;
  };
}
