{ pkgs, ... }: {
  home-manager.users.rhoriguchi.home.file.".docker/config.json".source =
    (pkgs.formats.json { }).generate "config.json" { auths = (import ../secrets.nix).docker.auths; };
}
