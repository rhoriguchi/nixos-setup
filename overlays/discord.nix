{ discord, fetchurl }:
discord.overrideAttrs (_: rec {
  version = "0.0.21";

  src = fetchurl {
    url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
    hash = "sha256-KDKUssPRrs/D10s5GhJ23hctatQmyqd27xS9nU7iNaM=";
  };
})
