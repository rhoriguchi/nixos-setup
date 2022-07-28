{ pkgs, secrets, ... }: {
  home-manager.users.rhoriguchi.home.file.".docker/config.json".source =
    (pkgs.formats.json { }).generate "config.json" { auths = secrets.docker.auths; };
}
