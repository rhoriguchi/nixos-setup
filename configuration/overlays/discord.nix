{ discord, fetchurl }:
discord.overrideAttrs (_: rec {
  version = "0.0.16";

  src = fetchurl {
    url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
    hash = "sha256-UTVKjs/i7C/m8141bXBsakQRFd/c//EmqqhKhkr1OOk=";
  };
})
