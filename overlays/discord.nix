{ discord, fetchurl }:
discord.overrideAttrs (_: rec {
  version = "0.0.18";

  src = fetchurl {
    url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
    hash = "sha256-BBc4n6Q3xuBE13JS3gz/6EcwdOWW57NLp2saOlwOgMI=";
  };
})
