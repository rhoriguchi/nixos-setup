{ teamviewer, fetchurl }:
teamviewer.overrideAttrs (oldAttrs: rec {
  version = "15.9.5";

  src = fetchurl {
    url =
      "https://dl.tvcdn.de/download/linux/version_15x/teamviewer_${version}_amd64.deb";
    sha256 = "1wnh4xdll7wgkh51g1as72i0vjbzj3r4zyw8al6nd14la93hxnbg";
  };
})
