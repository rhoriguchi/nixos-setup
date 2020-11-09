# { pkgs, stdenv, fetchurl }: TODO do it like this
# TODO create pull request with arm64
{ pkgs }:
let
  arch = {
    x86_64-linux = "x64";
    i686-linux = "i386";
    aarch64-linux = "arm64";
  }.${pkgs.stdenv.hostPlatform.system} or (throw
    "Unsupported system: ${pkgs.stdenv.hostPlatform.system}");
in pkgs.resilio-sync.overrideAttrs (oldAttrs: {
  src = pkgs.fetchurl {
    url =
      "https://download-cdn.resilio.com/${oldAttrs.version}/linux-${arch}/resilio-sync_${arch}.tar.gz";
    sha256 = {
      x86_64-linux = "0gar5lzv1v4yqmypwqsjnfb64vffzn8mw9vnjr733fgf1pmr57hf";
      i686-linux = "1bws7r86h1vysjkhyvp2zk8yvxazmlczvhjlcayldskwq48iyv6w";
      aarch64-linux = "0j8wk5cf8bcaaqxi8gnqf1mpv8nyfjyr4ibls7jnn2biqq767af2";
    }.${pkgs.stdenv.hostPlatform.system};
  };
})
