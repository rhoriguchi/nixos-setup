{ secrets, ... }: {
  services = {
    infomaniak = {
      enable = true;

      username = secrets.infomaniak.username;
      password = secrets.infomaniak.password;
      hostnames = [ "minecraft.00a.ch" ];
    };

    minecraft-server = {
      enable = true;
      eula = true;

      openFirewall = true;

      jvmOpts = let memory = 1024 * 4; in "-Xmx${toString memory}M -Xms${toString memory}M";

      declarative = true;

      # https://minecraft.fandom.com/wiki/Server.properties
      serverProperties = rec {
        motd = "Pingu Land";
        white-list = true;

        difficulty = "normal";
        view-distance = 16;
      };

      # https://mcuuid.net
      whitelist = {
        Jeum = "f9fbd9b1-bb8b-4aa6-8e40-b6cc67905487"; # Jessy
        nielsx3 = "a2d4ac95-9a30-4f88-946c-05b60cfaf28b"; # Niels
        Papierschorle = "fd048705-cb86-4e31-a251-1a99d5d2483f"; # Ramon
        Probefahrer = "bbc822d0-2ad2-44f1-94c3-e185cf4d74b4"; # Cyrill
        Sirkii = "5e14c507-16cd-4a0d-84bd-ec82c1792e03"; # Keanu
        ThatOneSlave = "ee4c4772-23d4-4cc9-9f70-092aa1ddc7c2"; # Janik
        XXLPitu = "91469f95-dded-484b-acde-1da375f88aed"; # Ryan
      };
    };
  };
}
