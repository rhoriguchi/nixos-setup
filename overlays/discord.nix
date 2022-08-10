{ discord, fetchurl }:
discord.overrideAttrs (_: rec {
  version = "0.0.19";

  src = fetchurl {
    url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
    hash = "sha256-GfSyddbGF8WA6JmHo4tUM27cyHV5kRAyrEiZe1jbA5A=";
  };
})
