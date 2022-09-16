{ discord, fetchurl }:
discord.overrideAttrs (_: rec {
  version = "0.0.20";

  src = fetchurl {
    url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
    hash = "sha256-3f7yuxigEF3e8qhCetCHKBtV4XUHsx/iYiaCCXjspYw=";
  };
})
