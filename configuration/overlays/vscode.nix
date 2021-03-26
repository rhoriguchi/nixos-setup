{ vscode, fetchurl }:
let
  plat = "linux-x64";
  archive_fmt = "tar.gz";
  sha256 = "1px6x99cv8nb8lcy3vgcicr4ar0bfj5rfnc5a1yw8rs5p1qnflgw";
in vscode.overrideAttrs (oldAttrs: rec {
  version = "1.54.2";

  src = fetchurl {
    name = "VSCode_${version}_${plat}.${archive_fmt}";
    url = "https://update.code.visualstudio.com/${version}/${plat}/stable";
    inherit sha256;
  };
})
