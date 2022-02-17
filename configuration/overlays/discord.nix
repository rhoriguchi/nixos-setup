{ discord, fetchurl }:
discord.overrideAttrs (_: rec {
  version = "0.0.17";

  src = fetchurl {
    url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
    hash = "sha256-NGJzLl1dm7dfkB98pQR3gv4vlldrII6lOMWTuioDExU=";
  };
})
