{ pkgs, config, ... }: {
  imports = [ ./mods ];

  nixpkgs.overlays = [
    (self: super: {
      factorio-headless = super.factorio-headless.overrideAttrs (_: rec {
        version = "1.1.57";

        src = pkgs.fetchurl {
          name = "factorio_headless_x64-${version}.tar.xz";
          url = "https://factorio.com/get-download/${version}/headless/linux64";
          sha256 = "sha256-tWHdy+T2mj5WURHfFmALB+vUskat7Wmeaeq67+7lxfg=";
        };
      });
    })
  ];

  services = {
    factorio = {
      enable = true;

      openFirewall = true;

      admins = [ "Papierschorle" "XXLPitu" ];

      game-name = "World 2022";
      game-password = (import ../../../../secrets.nix).services.factorio.game-password;

      saveName = "World";
      autosave-interval = 10;

      extraSettings = {
        afk_autokick_interval = 30;
        autosave_slots = 10;
        max_upload_slots = 25;
      };
    };

    infomaniak.hostnames = [ "factorio.00a.ch" ];
  };
}
